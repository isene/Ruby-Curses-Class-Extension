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
  attr_accessor :fg, :bg, :attr, :text, :update, :index
  def self.pair(fg, bg)
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
  def clr # Clears the whole window
    self.setpos(0, 0)
    self.maxy.times {self.deleteln()}
    self.refresh
    self.setpos(0, 0)
  end
  def clr_to_cur_line
    l = self.cury
    self.setpos(0, 0)
    l.times {self.deleteln()}
    self.refresh
  end
  def clr_from_cur_line
    l = self.cury
    (self.maxy - l).times {self.deleteln()}
    self.refresh
    self.setpos(l, 0)
  end
  def fill # Fill window with color as set by self.color (or self.bg if not set) 
    self.setpos(0, 0)
    self.fill_from_cur_pos
  end
  def fill_to_cur_pos # Fills the window up to current line
    x = self.curx
    y = self.cury
    self.setpos(0, 0)
    self.bg = 0 if self.bg   == nil
    self.fg = 255 if self.fg == nil
    blank = " " * self.maxx
    cp = Curses::Window.pair(self.fg, self.bg)
    y.times {self.attron(color_pair(cp)) {self << blank}}
    self.refresh
    self.setpos(y, x)
  end
  def fill_from_cur_pos # Fills the rest of the window from current line
    x = self.curx
    y = self.cury
    self.setpos(y, 0)
    self.bg = 0 if self.bg   == nil
    self.fg = 255 if self.fg == nil
    blank = " " * self.maxx
    cp = Curses::Window.pair(self.fg, self.bg)
    self.maxy.times {self.attron(color_pair(cp)) {self << blank}}
    self.refresh
    self.setpos(y, x)
  end
  def write
    self.attr = 0 if self.attr == nil
    self.bg = 0 if self.bg   == nil
    self.fg = 255 if self.fg == nil
    cp = Curses::Window.pair(self.fg, self.bg)
    self.attron(color_pair(cp) | self.attr) { self << self.text }
    self.refresh
  end
  def p(text) # Puts text to window
    self.attr = 0 if self.attr == nil
    self.bg = 0 if self.bg   == nil
    self.fg = 255 if self.fg == nil
    cp = Curses::Window.pair(self.fg, self.bg)
    self.attron(color_pair(cp) | attr) { self << text }
    self.refresh
  end
  def pclr(text) # Puts text to window and clears the rest of the window
    self.p(text)
    self.clr_from_cur_line
  end
  def pa(fg = self.fg, bg = self.bg, attr = self.attr, text) # Puts text to window with full set of attributes
    cp = Curses::Window.pair(fg, bg)
    self.attron(color_pair(cp) | attr) { self << text }
    self.refresh
  end
  def paclr(fg = self.fg, bg = self.bg, attr = self.attr, text) # Puts text to window with full set of attributes and clears rest of window
    self.pa(fg, bg, attr, text)
    self.clr_from_cur_line
  end
  def format_text(text) # Format text so that it linebreaks neatly inside window
    return "\n" + text.gsub(/(.{1,#{self.maxx}})( +|$\n?)|(.{1,#{self.maxx}})/, "\\1\\3\n")
  end
  alias :puts :p
end

