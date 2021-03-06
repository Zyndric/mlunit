function t = test_test_loader(name)
%test_test_loader tests the class test_loader.
%
%  Example
%  =======
%         run(mlunit_gui, 'test_test_loader');
%
%  See also TEST_LOADER.

%  �Author: Thomas Dohmke <thomas@dohmke.de> �
%  $Id: test_test_loader.m 46 2006-06-11 19:20:00Z thomi $

t.dummy = 0;
tc = test_case(name);
t = class(t, 'test_test_loader', tc);
