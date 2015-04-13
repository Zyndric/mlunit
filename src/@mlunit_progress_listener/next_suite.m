%Update display with next pending test suite.
%
%  SELF = next_suite(SELF, NAME) notifies the listener of an impending suite
%  execution, providing it with the name of the suite.
%  SELF is a mlunit_progress_listener_gui instance.
%  NAME is the test suite name.
%
%  This method is provided by the user, but should not be called by her.
%
%  See also init_suites

%  This Software and all associated files are released unter the 
%  GNU General Public License (GPL), see LICENSE for details.
%  
%  $Id$

function self = next_suite(self, name)

error('MLUNIT:missingOverload', 'Abstract base implementation for method ''%s''needs overloading.', mfilename);
