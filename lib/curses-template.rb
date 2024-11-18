#!/usr/bin/env ruby
# encoding: utf-8

# This is a basic template for my? Curses applications. Feel free to use.
# 
# It is an example of a basic curses application with 4 windows like this:
#
# +-------------------------------+
# | @w_t                          |
# +---------------+---------------+
# | @w_l          | @w_r          |
# |               |               |
# |               |               |
# |               |               |
# +---------------+---------------+
# | @w_b                          |
# +-------------------------------+

begin #Basic setup
  require 'io/console'
  require 'io/wait'
  require 'curses'
  include  Curses

  Curses.init_screen
  Curses.start_color
  Curses.curs_set(0)
  Curses.noecho
  Curses.cbreak
  Curses.stdscr.keypad = true
end

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

# GENERAL FUNCTIONS 
def getchr # Process key presses
  c = STDIN.getch
  #c = STDIN.getch(min: 0, time: 1) # Use this if you need to poll for user keys
  case c
  when "\e"    # ANSI escape sequences
    case STDIN.getc
    when '['   # CSI
      case STDIN.getc
      when 'A' then chr = "UP"
      when 'B' then chr = "DOWN"
      when 'C' then chr = "RIGHT"
      when 'D' then chr = "LEFT"
      when 'Z' then chr = "S-TAB"
      when '2' then chr = "INS"    ; chr = "C-INS"    if STDIN.getc == "^"
      when '3' then chr = "DEL"    ; chr = "C-DEL"    if STDIN.getc == "^"
      when '5' then chr = "PgUP"   ; chr = "C-PgUP"   if STDIN.getc == "^"
      when '6' then chr = "PgDOWN" ; chr = "C-PgDOWN" if STDIN.getc == "^"
      when '7' then chr = "HOME"   ; chr = "C-HOME"   if STDIN.getc == "^"
      when '8' then chr = "END"    ; chr = "C-END"    if STDIN.getc == "^"
      end
    when 'O'   # Set Ctrl+ArrowKey equal to ArrowKey; May be used for other purposes in the future
      case STDIN.getc
      when 'a' then chr = "C-UP"
      when 'b' then chr = "C-DOWN"
      when 'c' then chr = "C-RIGHT"
      when 'd' then chr = "C-LEFT"
      end
    end
  when "", "" then chr = "BACK"
  when "" then chr = "C-C"
  when "" then chr = "C-D"
  when "" then chr = "C-E"
  when "" then chr = "C-G"
  when "" then chr = "C-K"
  when "" then chr = "C-L"
  when "" then chr = "C-N"
  when "" then chr = "C-O"
  when "" then chr = "C-P"
  when "" then chr = "C-T"
  when "" then chr = "C-Y"
  when "" then chr = "WBACK"
  when "" then chr = "LDEL"
  when "\r" then chr = "ENTER"
  when "\t" then chr = "TAB"
  when /[[:print:]]/  then chr = c
  end
  return chr
end
def main_getkey # GET KEY FROM USER
  chr = getchr
  case chr
  when '?' # Show helptext in right window - add code to show help text here
    @w_t.p0(255,27,"Try pressing 'w'")
    @w_t.update = false
  # Examples of moving up and down in a window
  # You must set @min_index and @max_index in the main loop of the program 
  when 'UP' 
    @w_l.index = @w_l.index <= @min_index ? @max_index : @w_l.index - 1
  when 'DOWN'
    @w_l.index = @w_l.index >= @max_index ? @min_index : @w_l.index + 1
  when 'PgUP'
    @w_l.index -= @w_l.maxy - 2
    @w_l.index = @min_index if @w_l.index < @min_index
  when 'PgDOWN'
    @w_l.index += @w_l.maxy - 2
    @w_l.index = @max_index if @w_l.index > @max_index
  when 'HOME'
    @w_l.index = @min_index
  when 'END'
    @w_l.index = @max_index
  when 'w' # Shows how you can add a window and get input from there and then close the window
    maxx = Curses.cols
    maxy = Curses.lines
    # Curses::Window.new     (     h,      w,        y,         x)
    @w_w = Curses::Window.new(     6,     20, maxy/2-3, maxx/2-10)
    @w_w.fg, @w_w.bg, @w_w.attr = 255, 233, Curses::A_BOLD
    @w_w.frame
    @w_w.setpos(4, 7) 
    @w_w.p(255,130," y/n? ")
    chrw = getchr
    case chrw
    when 'y'
      @w_w.setpos(4, 7) 
      @w_w.p(255,22," YES! ")
    when 'n'
      @w_w.setpos(4, 7) 
      @w_w.p(255,52," NO!! ")
    end
    chrw = getchr
    @w_l.fill; @w_r.fill # Fill the underlying windows to remove the overlaying window
    @w_w.close # Remove the overlying window from memory
  when 'a'
    # ...etc
  when 'r'
    @break = true
  when 'q' # Exit 
    exit 0
  when '@' # Enter "Ruby debug"
    cmd = w_b_getstr("◆ ", "")
    @w_b.update = true
    @w_r.fill
    info = "Command: #{cmd}\n\n"
    begin
      info += eval(cmd).to_s
    rescue Exception => err
      info += "Error: #{err.inspect}"
    end
    w_r_info(info)
    @w_r.update = false
    cmd = w_b_getstr("◆ ", "")
    begin
      @w_r.fill
      @w_r.p(eval(cmd))
    rescue StandardError => e
      w_b("Error: #{e.inspect}")
      chr = STDIN.getc
    end
  end
  while STDIN.ready?
    chr = STDIN.getc
  end
end

# TOP WINDOW FUNCTIONS 

# BOTTOM WINDOW FUNCTIONS 
def w_b(info) # SHOW INFO IN @W_B
  @w_b.fill
  info      = "Choose window: i=IMDB list (+/- to add/remove from my? list), g=Genres (+/- to add/remove), m=my? list. " if info == nil
  info      = info[1..(@w_b.mx? - 3)] + "…" if info.length + 3 > @w_b.mx? 
  info     += " " * (@w_b.mx? - info.length) if info.length < @w_b.mx?
  @w_b.p(info)
  @w_b.nl
  @w_b.update = false
end
def w_b_getstr(pretext, text) # A SIMPLE READLINE-LIKE ROUTINE
  Curses.curs_set(1)
  Curses.echo
  stk = 0
  pos = text.length
  chr = ""
  while chr != "ENTER"
    @w_b.xy(0,0)
    @w_b.p(pretext + text)
    @w_b.nl
    @w_b.xy(pretext.length + pos,0)
    @w_b.refresh
    chr = getchr
    case chr
    when 'C-C', 'C-G'
      return ""
    when 'RIGHT'
      pos += 1 unless pos > text.length
    when 'LEFT'
      pos -= 1 unless pos == 0
    when 'HOME'
      pos = 0
    when 'END'
      pos = text.length
    when 'DEL'
      text[pos] = ""
    when 'BACK'
      unless pos == 0
        pos -= 1
        text[pos] = ""
      end
    when 'LDEL'
      text = ""
      pos = 0
    when /^.$/
      text.insert(pos,chr)
      pos += 1
    end
  end
  Curses.curs_set(1); Curses.curs_set(0) 
  #Curses.noecho
  return text
end

# LEFT WINDOW FUNCTIONS

# RIGHT WINDOW FUNCTIONS 
def w_r_info(info) # SHOW INFO IN THE RIGHT WINDOW
  begin
    @w_r.clr
    @w_r.refresh
    @w_r.p(info)
    @w_r.update = false
  rescue
  end
end

# MAIN PROGRAM 
loop do # OUTER LOOP - (catching refreshes via 'r')
  @break = false # Initialize @break variable (set if user hits 'r')
  begin # Create the four windows/panes 
    maxx = Curses.cols
    maxy = Curses.lines
    # Create windows/panes
    # Curses::Window.new     (     h,      w,      y,      x)
    @w_t = Curses::Window.new(     1,   maxx,      0,      0)
    @w_b = Curses::Window.new(     1,   maxx, maxy-1,      0)
    @w_l = Curses::Window.new(maxy-2, maxx/2,      1,      0)
    @w_r = Curses::Window.new(maxy-2, maxx/2,      1, maxx/2)
    # Set foreground and background colors and attributes
    @w_t.fg, @w_t.bg, @w_t.attr = 255,  23, 0
    @w_b.fg, @w_b.bg, @w_b.attr = 231, 238, 0
    @w_l.fg, @w_l.bg, @w_l.attr =  24, 233, 0
    @w_r.fg, @w_r.bg, @w_r.attr = 202, 235, 0
    @w_t.update = true
    @w_b.update = true
    @w_l.update = true
    @w_r.update = true
    @w_l.fill; @w_r.fill
    loop do # INNER, CORE LOOP 
      # Example code to write to the panes in various ways
      @w_t.p0("Top window") if @w_t.update
      @w_b.p0("Bottom window - try pressing '?'") if @w_b.update
      @w_l.frame
      @w_l.xy(@w_l.mx?/2-6, @w_l.my?/2)
      @w_l.p(87,17,Curses::A_BOLD,"Left window")
      @w_l.fill(24, 1, 2)
      @w_l.fill(24,@w_l.my?-2,@w_l.my?-1)
      @w_r.xy(@w_r.mx?/2-7, @w_r.my?/2)
      @w_r.p("Right window") if @w_r.update
      
      # Top window (info line) 
      
      # Bottom window (command line)

      # Left window

      # Right window

      # Clear residual cursor
      Curses.curs_set(1); Curses.curs_set(0) 

      # Get key from user 
      main_getkey

      break if @break    # Break to outer loop, redrawing windows, if user hits 'r'
      break if Curses.cols != maxx or Curses.lines != maxy # break on terminal resize 
    end
  ensure # On exit: close curses, clear terminal 
    close_screen
  end
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
