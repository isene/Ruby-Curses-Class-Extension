# Ruby-Curses-Class-Extension
Extending the Ruby Curses module with some obvious needed functionality.

No more fiddling with color pairs. No more manual filling lines or framing.

With this extension, you don't need to initiate any color pairs or add text to
windows with odd syntax. Use any foreground and backround color you see fit
and let this extension take care of the weird need to pair colors and initiate
the color pairs. You also get a bunch of extra methods to manipulate curses
windows.

With this extension writing text to windows becomes a breeze. You can set
default foreground, background and attribute for a window (e.g. `win.fg =
124`, `win.bg = 234` and `win.attr = Curses::A_BOLD`) - and you can write text
to a window with `win.p("Hello World")` where the defaults will be applied.
You can override the defaults with e.g. `win.p(124, "Hello World")` to write
the text in red or `win.p(76, 240, Curses::A_BOLD, "Hello World")` to write
the text in bold green on a gray background. 

There is also the handy method `nl` that fills the rest of the line with
spaces and (optional) background color, making it an effective newline.

And then there is the convenient `frame`method that adds a... frame to the
window.

The `curses-template.rb` contains code that helps you understand how you can
easily create curses applications in Ruby. It is a fully runnable app that
doesn't do much - but you can fiddle around with the code and test
functionality for yourself. 

## Attributes
Attribute           | Description
--------------------|--------------------------------------------------------
fg                  | Foreground color for window (0-255)
bg                  | Background color for window (0-255)
attr                | Attributes for window (such as Curses::A_BOLD) - string with "\|" (such as Curses::A_BOLD \| Curses::A_UNDERLINE)
update				| Whether to update the window on the next refresh
index				| Used to track an index for each window (used to display lists such as the content of a directory, etc.)

## Functions
Parameters in square are optional.

Function							| Description
------------------------------------|--------------------------------------------------------
clr							| Clears window without flicker (win.clear flickers)
clr_to_cur_line				| Clears the window up to the current line
clr_from_cur_line			| Clears the rest of the window after the current line
fill						| Fill window with color as set by :color ( or :bg if not :color is set)
fill_to_cur_pos				| Fill the window up to the current line
fill_from_cur_pos			| Fill the rest of the window after the current line
p([fg], [bg], [attr], text)	| Write text to window with fg/bg and attributes (will handle the exceptions if no colors are set)
							  You can use `puts` instead of `p` (it's an alias). `fg`, `bg` and `attr` are optional parameters
pclr(text)					| As `p(text)` but also clears the rest of the window
nl([bg])                    | Newline. Puts spaces with (optional) background colors until the end of the line
frame([fg],[bg])			| Frame the window
format(text)				| Format text so that it linebreaks neatly inside window

## Curses template
The `curses_template.rb` includes the class extension and serves as the basis for my curses applications. It is a runnable curses application that does nothing.
