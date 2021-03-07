class Curses::Window # CLASS EXTENSION 
  # General extensions (see https://github.com/isene/Ruby-Curses-Class-Extension)
  attr_accessor :color, :fg, :bg, :attr, :update
  # Set self.color for an already defined color pair such as: init_pair(1, 255, 3)
  # The color pair is defined like this: init_pair(index, foreground, background)
  # self.fg is set for the foreground color (and is used if self.color is not set)
  # self.bg is set for the background color (and is used if self.color is not set)
  # self.attr is set for text attributes like Curses::A_BOLD
  def clr # Clears the whole window
    self.setpos(0, 0)
    self.maxy.times {self.deleteln()}
    self.refresh
    self.setpos(0, 0)
  end
  def fill # Fill window with color as set by self.color (or self.bg if not set) 
    self.setpos(0, 0)
    self.fill_from_cur_pos
  end
  def fill_from_cur_pos # Fills the rest of the window from current line
    x = curx
    y = cury
    self.setpos(y, 0)
    blank = " " * self.maxx
    if self.color == nil
      self.bg = 0 if self.bg   == nil
      self.fg = 255 if self.fg == nil
      init_pair(self.fg, self.fg, self.bg)
      self.maxy.times {self.attron(color_pair(self.fg)) {self << blank}}
    else
      self.maxy.times {self.attron(color_pair(self.color)) {self << blank}}
    end
    self.refresh
    self.setpos(y, x)
  end
  def fill_to_cur_pos # Fills the window up to current line
    x = curx
    y = cury
    self.setpos(0, 0)
    blank = " " * self.maxx
    if self.color == nil
      self.bg = 0 if self.bg   == nil
      self.fg = 255 if self.fg == nil
      init_pair(self.fg, self.fg, self.bg)
      y.times {self.attron(color_pair(self.fg)) {self << blank}}
    else
      y.times {self.attron(color_pair(self.color)) {self << blank}}
    end
    self.refresh
    self.setpos(y, x)
  end
  def p(text) # Puts text to window
    self.attr = 0 if self.attr == nil
    if self.color == nil
      self.bg = 0 if self.bg   == nil
      self.fg = 255 if self.fg == nil
      init_pair(self.fg, self.fg, self.bg)
      self.attron(color_pair(self.fg) | self.attr) { self << text }
    else
      self.attron(color_pair(self.color) | self.attr) { self << text }
    end
    self.refresh
  end
  def pa(fg, bg, attr, text) # Puts text to window with full set of attributes
    self.fg = fg
    self.bg = bg
    self.attr = attr
    init_pair(self.fg, self.fg, self.bg)
    self.attron(color_pair(self.fg) | self.attr) { self << text }
    self.refresh
  end
end
