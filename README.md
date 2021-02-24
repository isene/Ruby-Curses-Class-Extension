# Ruby-Curses-Class-Extension
Extending the Ruby Curses module with some obvious functionality

## Attributes
Attribute         | Description
------------------|--------------------------------------------------------
:color            | Set the window's color to an already initiated color pair (with `init_pair(index, forground, backround`)
:fg               | Foreground color for window (0-255)
:bg               | Background color for window (0-255)
:attr             | Attributes for window (such as Curses::A_BOLD) - string with "\|" (such as Curses::A_BOLD \| Curses::A_UNDERLINE)

## Functions
Function          | Description
------------------|--------------------------------------------------------
clr               | Clears window without flicker (win.clear flickers)
fill              | Fill window with color as set by :color ( or :bg if not :color is set)
fill_from_cur_pos | Fill the rest of the window after the current line
fill_to_cur_pos   | Fill the window up to the current line
p(text)           | Write to window with color or fg/bg and attributes (will handle the exceptions if no colors are set)

## Curses template
The `curses_template.rb` includes the class extension and serves as the basis for my curses applications.
