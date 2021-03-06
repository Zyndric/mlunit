function self = generic_test(self)

name = get_name(self.test_case);
test_name_contains = @(q) ~isempty(strfind(name, q));

if test_name_contains('test_assert')
    mlunit_fail('This is an assert_* call in the test.');
end

if test_name_contains('test_error')
    error('This is a runtime error in the test.');
end

if test_name_contains('test_skip')
    mlunit_skip('This is a runtime skip request in the test.');
end
