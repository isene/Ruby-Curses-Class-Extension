# Ruby-Curses-Class-Extension
Extending the Ruby Curses module with some obvious functionality

## Attributes
Attribute | Description
----------|--------------------------------------------------------
:fg       | Foreground color for window (0-255)
:bg       | Background color for window (0-255)
:attr     | Attributes for window (such as Curses::A_BOLD) - string with "\|" (such as Curses::A_BOLD | Curses::A_UNDERLINE)
:text     | The text that is to be written to the window
:update   | Whether the window is to be updated (true) or not (false)

## Functions
Function  | Description
----------|--------------------------------------------------------
clr       | Clears window without flicker (win.clear flickers)
fill      | Fill window with color as set by :bg
write     | Write context of :text to window with attributes :attr

