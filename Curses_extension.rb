class Curses::Window # CLASS EXTENSION 
  attr_accessor :fg, :bg, :attr, :text, :update
  def clr # Clears window without flicker (win.clear flickers)
    self.setpos(0, 0)
    self.maxy.times {self.deleteln()}
    self.refresh
    self.setpos(0, 0)
  end
  def fill # Fill window with color as set by :bg
    self.setpos(0, 0)
    init_pair(self.fg, self.fg, self.bg)
    blank = " " * self.maxx
    self.maxy.times {self.attron(color_pair(self.fg)) {self << blank}}
    self.refresh
    self.setpos(0, 0)
  end
  def write # Write context of :text to window with attributes :attr
    init_pair(self.fg, self.fg, self.bg)
    self.attron(color_pair(self.fg) | self.attr) { self << self.text }
    self.refresh
  end
end
