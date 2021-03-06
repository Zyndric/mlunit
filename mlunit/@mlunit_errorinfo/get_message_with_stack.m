%Get an error's message and stack as single string.
%  get_message_with_stack works on the internally buffered error information
%  that you provided in mlunit_errorinfo's constructor. The actual message and
%  stack get processed according to it being an mlUnit failure or a plain error.
%
%  message = get_message_with_stack(self) returns a char array containing the
%  message and stack.
%
%  The stack format can be changed by the mlUnit parameter 'linked_trace'.

%  This Software and all associated files are released unter the 
%  GNU General Public License (GPL), see LICENSE for details.
%  
%  $Id$

function message = get_message_with_stack(self)

% obtain message and stack
[message, stack] = filter_lasterror_wraps(self);

% reduce the stack of failures or skips for better overview
% if is_failure(self) || is_skipped(self)
    stack = filter_failure_stack(self, stack);
% end

% put message and stack together
message = [message, loc_print_stack(stack)];


%Build a single stactracke string out of a stack structure.
%If there are stack items at all, start with a leading newline.
%  stack is the stack structure as returned by lasterror().stack or dbstack().
function stackstring = loc_print_stack(stack)

stackstring = '';
for i = 1:size(stack, 1)
    stackstring = sprintf('%s\n%s', ...
        stackstring, ...
        loc_print_stackline(stack(i)));
end

% Build a single stacktrace line for a single stacktrace item.
%   stackitem has fields as returned by lasterror().stack or dbstack().
function stackline = loc_print_stackline(stackitem)

display_name = stackitem.file;
if mlunit_param('abbrev_trace')
    [dummy, filename, ext] = fileparts(stackitem.file);
    display_name = [filename ext];
end

if mlunit_param('linked_trace')
    hrefvalue = sprintf('matlab:opentoline(''%s'',%d)', ...
        stackitem.file, stackitem.line);
    stackline = sprintf('In <a href="%s">%s</a> at line %d', ...
        hrefvalue, display_name, stackitem.line);
else
    stackline = sprintf('In %s at line %d', ...
        display_name, stackitem.line);
end
