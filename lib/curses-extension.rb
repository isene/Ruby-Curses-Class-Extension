class Curses::Window # CLASS EXTENSION 
  # General extensions (see https://github.com/isene/Ruby-Curses-Class-Extension)
  # This is a class extension to Ruby Curses - a class in dire need of such.
  # self.pair keeps a registry of colors as they are encountered - defined with: 
  # init_pair(index, foreground, background)
  # self.fg is set for the foreground color
  # self.bg is set for the background color
  # self.attr is set for text attributes like Curses::A_BOLD
  # self.update can be used to indicate if a window should be updated (true/false)
  # self.index can be used to keep track of the current list item in a window
  attr_accessor :fg, :bg, :attr, :framed, :update, :index
  def self.pair(fg, bg) # INTERNAL FUNCTION
    @p = [[]] if @p == nil
    fg = fg.to_i; bg = bg.to_i
    if @p.include?([fg,bg])
      @p.index([fg,bg])
    else
      @p.push([fg,bg])
      cp = @p.index([fg,bg])
      init_pair(cp, fg, bg)
      @p.index([fg,bg])
    end
  end
  def x? # GET THE CURRENT X (COLUMN)
    x  = self.curx
    x -= 1 if self.framed
    x
  end
  def y? # GET THE CURRENT Y (ROW)
    y  = self.cury
    y -= 1 if self.framed
    y
  end
  def mx? # GET THE MAXIMUM X (COLUMN)
    mx  = self.maxx
    mx -= 2 if self.framed
    mx
  end
  def my? # GET THE MAXIMUM Y (ROW)
    my  = self.maxy
    my -= 2 if self.framed
    my
  end
  def x(x) # SET/GOTO X (COLUMN)
    x  += 1 if self.framed
    mx  = self.mx?
    x   = mx if x > mx
    y   = self.cury
    self.setpos(y,x)
  end
  def y(y) # SET/GOTO Y (ROW)
    y  += 1 if self.framed
    my  = self.my?
    y   = my if y > my
    x   = self.curx
    self.setpos(y,x)
  end
  def xy(x,y) # SET/GOTO X & Y (COLUMN & ROW)
    x  += 1 if self.framed
    y  += 1 if self.framed
    mx  = self.mx?
    x   = mx if x > mx?
    my  = self.my?
    y   = my if y > my?
    self.setpos(y,x)
  end
  def fill(bg = self.bg, l1 = 0, l2 = self.my?) # FILL WINDOW WITH BG COLOR FROM LINES L1 TO L2 
    self.xy(0, l1)
    bg    = 0 if self.bg == nil
    blank = " " * self.mx?
    cp    = Curses::Window.pair(0, bg)
    lines = l2 - l1
    lines.times do
      y = self.y?
      self.attron(color_pair(cp)) {self << blank}
      self.xy(0,y+1)
    end
    self.refresh
    self.xy(0, 0)
  end
  def p(fg = self.fg, bg = self.bg, attr = self.attr, text) # PUTS TEXT TO WINDOW WITH FULL SET OF ATTRIBUTES
    fg   = 255 if fg   == nil
    bg   = 0   if bg   == nil
    attr = 0   if attr == nil
    cp   = Curses::Window.pair(fg, bg)
    self.attron(color_pair(cp) | attr) { self << text }
    self.refresh
  end
  def nl(bg = self.bg) # ADD NEWLINE
    y  = self.y?
    bg = 232 if bg == nil
    f  = " " * (self.mx? - self.x?)
    self.p(self.fg, bg, self.attr, f)
    self.xy(0,y+1)
  end
  def p0(fg = self.fg, bg = self.bg, attr = self.attr, text) # PUTS TEXT AT 0,0 AND CLEARS THE REST OF THE LINE
    self.xy(0, 0)
    self.p(fg, bg, attr, text)
    self.nl(bg)
    self.xy(0, 0)
  end
  def frame(fg = self.fg, bg = self.bg) # TOGGLE FRAMING OF THE WINDOW
    fr = self.framed
    tl = self.framed ? " " : "┌"
    tc = self.framed ? " " : "─"
    tr = self.framed ? " " : "┐"
    lr = self.framed ? " " : "│"
    bl = self.framed ? " " : "└"
    bc = self.framed ? " " : "─"
    br = self.framed ? " " : "┘"
    self.setpos(0,0)
    self.p(tl + tc*(self.maxx-2) + tr)
    (self.maxy-2).times do
      y  = self.cury
      mx = self.maxx
      self.setpos(y,0);      self.p(lr)
      self.setpos(y,maxx-1); self.p(lr)
    end
    self.p(bl + bc*(self.maxx-2) + br)
    if self.framed == nil
      self.framed = true
    else
      self.framed = !self.framed
    end
    self.xy(0,0)
  end
  def format(text) # FORMAT TEXT SO THAT IT LINEBREAKS NEATLY INSIDE WINDOW
    return "\n" + text.gsub(/(.{1,#{self.maxx}})( +|$\n?)|(.{1,#{self.maxx}})/, "\\1\\3\n")
  end
  alias :puts :p
  alias :puts0 :p0
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
