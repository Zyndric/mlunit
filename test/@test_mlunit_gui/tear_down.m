function self = tear_down(self)
%test_mlunit_gui/set_up tears down the fixture for
%test_mlunit_gui.

%  �Author: Thomas Dohmke <thomas@dohmke.de> �
%  $Id: tear_down.m 162 2007-01-04 11:38:53Z thomi $

close(self.runner);
% Give some time for MATLAB to actually close the GUI
% If not, the GUI remains open until the very end of execution.
pause(0.1);
