%Begin listening to incoming results.
%  SELF = INIT_RESULTS(SELF, MAXNUM) tells the listener to prepare herself for
%  subsequent next_result calls. There will be exactly MAXNUM next_result calls
%  for this run, each providing the result of one test case execution.
%
%  This method is provided by the user, but should not be called by her.
%
%  See also next_result

%  This Software and all associated files are released unter the 
%  GNU General Public License (GPL), see LICENSE for details.
%  
%  $Id$

function self = init_results(self, num_results)

error('MLUNIT:missingOverload', 'Abstract base implementation for method ''%s''needs overloading.', mfilename);
