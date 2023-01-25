# Ruby-Curses-Class-Extension
Extending the Ruby Curses module with some obvious functionality

## Attributes
Attribute           | Description
--------------------|--------------------------------------------------------
color               | Set the window's color to an already initiated color pair (with `init_pair(index, forground, backround`)
fg                  | Foreground color for window (0-255)
bg                  | Background color for window (0-255)
attr                | Attributes for window (such as Curses::A_BOLD) - string with "\|" (such as Curses::A_BOLD \| Curses::A_UNDERLINE)
update				| Whether to update the window on the next refresh

## Functions
Function							| Description
------------------------------------|--------------------------------------------------------
clr									| Clears window without flicker (win.clear flickers)
clr_to_cur_pos						| Clears the window up to the current line
clr_from_cur_pos					| Clears the rest of the window after the current line
fill								| Fill window with color as set by :color ( or :bg if not :color is set)
fill_to_cur_pos						| Fill the window up to the current line
fill_from_cur_pos					| Fill the rest of the window after the current line
p(text)								| Write text to window with color or fg/bg and attributes (will handle the exceptions if no colors are set)
pclr(text)							| As `p(text)` but also clears the rest of the window
pa(fg, bg, attr, text)				| Write text to window with specified fg, bg and attribute(s)
paclr(text)							| As `pa(text)` but also clears the rest of the window
print(text, fg=255, bg=0, attr=0)	| Print text (from current position) with optional attributes
puts(text, fg=255, bg=0, attr=0)	| Clears window and puts text with optional attributes
format_text(text)					| Format text so that it linebreaks neatly inside window

## Curses template
The `curses_template.rb` includes the class extension and serves as the basis for my curses applications.
