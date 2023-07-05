# Ruby-Curses-Class-Extension
Extending the Ruby Curses module with some obvious needed functionality.

## Attributes
Attribute           | Description
--------------------|--------------------------------------------------------
fg                  | Foreground color for window (0-255)
bg                  | Background color for window (0-255)
attr                | Attributes for window (such as Curses::A_BOLD) - string with "\|" (such as Curses::A_BOLD \| Curses::A_UNDERLINE)
text				| Holds the text to be written with the `write`method
update				| Whether to update the window on the next refresh
index				| Used to track an index for each window (used to display lists such as the content of a directory, etc.)

## Functions
Function							| Description
------------------------------------|--------------------------------------------------------
clr									| Clears window without flicker (win.clear flickers)
clr_to_cur_line						| Clears the window up to the current line
clr_from_cur_line					| Clears the rest of the window after the current line
fill								| Fill window with color as set by :color ( or :bg if not :color is set)
fill_to_cur_pos						| Fill the window up to the current line
fill_from_cur_pos					| Fill the rest of the window after the current line
write								| Write what is already stored in window.text with the set values for fg, bg and attr
p(text) or puts(test)				| Write text to window with fg/bg and attributes (will handle the exceptions if no colors are set)
pclr(text)							| As `p(text)` but also clears the rest of the window
pa(fg, bg, attr, text)				| Write text to window with specified fg, bg and attribute(s)
paclr(text, fg=255, bg=0, attr=0)	| As `pa(text)` but also clears the rest of the window
format_text(text)					| Format text so that it linebreaks neatly inside window

## Curses template
The `curses_template.rb` includes the class extension and serves as the basis for my curses applications. It is a runnable curses application that does nothing.
