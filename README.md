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

And then there is the convenient `frame`method that toggles a frame for the
window.

You may ask why the methods `xy`, `x?`, `y?`, `mx?` and `my?` as these must
surely be covered already by the original Ruby Curses::Window library? They
serve a special purpose as they take into account that a window can be framed.
In a framed window, the top left corner is not `0,0`as that would be the top
left frame position. The inside top left of the frame is actually `1,1`, but
these functions treat that position as `0,0` if the window is framed and as
`1,1` if it is not. So - when using these functions you don't have to think
about compensating for the frame. Everything works just fine whether the
window is framed or not.

The `curses-template.rb` contains code that helps you understand how you can
easily create curses applications in Ruby. It is a fully runnable app that
doesn't do much - but you can fiddle around with the code and test
functionality for yourself. 

## Attributes
Attribute           | Description
--------------------|--------------------------------------------------------
fg                  | Foreground color for window (0-255)
bg                  | Background color for window (0-255)
attr                | Attributes for window (such as Curses::A_BOLD) - combine with "\|" (such as Curses::A_BOLD \| Curses::A_UNDERLINE)
update				| Whether to update the window on the next refresh
index				| Used to track an index for each window (used to display lists such as the content of a directory, etc.)

## Functions/Methods
Each window has an additional set of methods/functions to the original Curses library.

In this extended set of methods/functions, the ones ending in a question mark
(like `x?`) is a query and will return a value, while the others will set a
value or create something.

Parameters in square are optional.

Function					 | Description
-----------------------------|-------------------------------------------------------
x?							 | Get the current x (column)
y?							 | Get the current y (row)
mx?							 | Get the maximum x (column)
my?							 | Get the maximum y (row)
x(x)						 | Set/goto x (column)
y(y)						 | Set/goto y (row)
xy(x,y)						 | Set/goto x & y (column & row)
fill([bg], [l1], [l2])		 | Fill window with bg color from lines l1 to l2
p([fg], [bg], [attr], text)	 | Puts text to window with full set of attributes
nl([bg])					 | Add newline
p0([fg], [bg], [attr], text) | Puts text at 0,0 and clears the rest of the line
frame([fg], [bg])			 | Toggle framing of the window
format(text)				 | Format text so that it linebreaks neatly inside window

## Curses template
The `curses_template.rb` includes the class extension and serves as the basis for my curses applications. It is a runnable curses application that does nothing.
