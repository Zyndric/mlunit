%Load a given suite and execute all its tests.
%  [RESULTS, TIME, SELF] = run_suite(SELF, NAME) executes all tests of the suite NAME.
%  NAME is a string denoting a test suite, which must exist on the MATLAB
%  path. SELF is an mlunit_suite_runner instance. If you want to have listeners
%  be notified of test results during suite execution, call add_listeners()
%  before calling run_suite().
%
%  RESULTS is an array of whatever run_test() returned as first argument.
%  TIME is the time needed for suite execution, in seconds.
%
%  After suite execution, the mlUnit environment will be reset to the state it
%  has before suite execution. See mlunit_environment.
%
%  Example
%     % run without listeners; execute in test/utils subdirectory
%     >> [results, time] = run_suite(mlunit_suite_runner, 'test_mlunit_param');
%
%  See also run_test, mlunit_environment

%  This Software and all associated files are released unter the 
%  GNU General Public License (GPL), see LICENSE for details.
%  
%  $Id$

function [results, time, self] = run_suite(self, name)

% reload test case file if modified in the same GUI session, e.g. during
% debugging
rehash;

suite_start_time = clock;

% Mlock mlunit_param for the duration of the suite execution.
% Unlock it again afterwards, if it was unlocked before.
% We actually get called from run_suite_collection, which handles mlunit_param
% locking itself, but we handle it again, since sometimes run_suite is called
% directly. Currently this is only in mlunit_gui/gui.m.
params_were_locked = mislocked('mlunit_param');
mlunit_param('-mlock');

% buffer environment for reset after suite execution
previous_environment = mlunit_environment();

% Load suite. Let errors bubble through, as we have no meaningful way of
% reporting them. This is equivalent to jUnit behaviour, where we are guaranteed
% to execute the tests only when they compiled, i.e. have no syntax errors.
if isempty(name)
    % empty name
    error('MLUNIT:emptyTestName', 'Test suite name is empty.');
elseif is_class_test(name)
    % from class
    testsuite = load_tests_from_test_case(test_loader, name);
else
    % from function
    testsuite = eval(name);
end

% execute suite set_up
suite_setup_error = [];
setup_obj = get_setup(testsuite);
try
    % invocation is different for function based or class based test cases
    % cannot use a suite_set_up derivative in function_test_case, since there
    % would be no fall-back to test_case's suite_set_up in case there is no
    % override
    if isa(setup_obj, 'function_test_case')
        run_test(setup_obj);
    else
        suite_set_up(setup_obj);
    end
catch
    suite_setup_error = mlunit_errorinfo(lasterror, 'Error in suite_set_up (occurred once for this suite, but is relevant for every test case):');
end

tests = get_tests(testsuite);
num_tests = numel(tests);

% execute tests only if no error in suite setup
if isempty(suite_setup_error)

    self = notify_listeners(self, 'init_results', num_tests);

    % run each test of the suite; be sure to update the self state with each call
    results = cell(size(tests));
    for t=1:numel(tests)
        [results{t}, self] = run_test(self, tests{t});
    end
    % convert back into normal array; we went around by using a cell array, because
    % MATLAB is picky when we put them into a plain array directly in the loop
    results = [results{:}];

% In case of suite setup error, patch together one single test result,
% so that the setup error is contained and inform listeners accordingly.
else
    self = notify_listeners(self, 'init_results', 1);
    results = loc_single_result('suite_set_up', suite_setup_error);
    self = notify_listeners(self, 'next_result', results(1));
end

% execute suite tear_down
teardown_obj = get_teardown(testsuite);
teardownFailResult = [];
try
    % invocation is different for function based or class based test cases
    % see also suite_set_up above
    if isa(teardown_obj, 'function_test_case')
        run_test(teardown_obj);
    else
        suite_tear_down(teardown_obj);
    end
catch
    suite_teardown_error = mlunit_errorinfo(lasterror, 'Error in suite_tear_down (occurred once for this suite, but is relevant for every test case):');
    teardownFailResult = loc_single_result('suite_tear_down', suite_teardown_error);
end

% restore environment after suite execution
[dummy, rmdirErrors] = mlunit_environment(previous_environment);
if ~isempty(rmdirErrors)
    rmdirErrorinfo = mlunit_errorinfo(rmdirErrors, 'Error(s) removing temporary directories after suite_test_down fixture:');
    if isempty(teardownFailResult)
        teardownFailResult = loc_single_result('suite_tear_down', rmdirErrorinfo);
    else
        teardownFailResult.errors{end+1} = rmdirErrorinfo;
    end
end

if ~isempty(teardownFailResult)
    % notify listeners of surplus test carrying the teardown error; add to list
    self = notify_listeners(self, 'next_result', result);
    results(end+1) = result;
end

% restore previous lock state of mlunit_param
if ~params_were_locked
    munlock('mlunit_param');
end

time = etime(clock, suite_start_time);


function result = loc_single_result(name, error)

    result = struct();
    result.name = name;
    result.errors = {error};
    result.failure = '';
    result.skipped = '';
    result.time = 0;
    result.console = '';
