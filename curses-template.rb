#!/usr/bin/env ruby
# encoding: utf-8

# This is a basic template for my Curses applications. Feel free to use.
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
  attr_accessor :fg, :bg, :attr, :update, :index
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
  def p(fg = self.fg, bg = self.bg, attr = self.attr, text) # Puts text to window with full set of attributes
    fg   = 255 if fg   == nil
    bg   = 0   if bg   == nil
    attr = 0   if attr == nil
    cp   = Curses::Window.pair(fg, bg)
    self.attron(color_pair(cp) | attr) { self << text }
    self.refresh
  end
  def nl(bg = self.bg)
    bg = 232 if bg == nil
    f  = " " * (self.maxx - self.curx)
    self.p(self.fg, bg, self.attr, f)
  end
  def pclr(fg = self.fg, bg = self.bg, attr = self.attr, text) # Puts text to window with full set of attributes and clears rest of window
    self.p(fg, bg, attr, text)
    self.clr_from_cur_line
  end
  def format(text) # Format text so that it linebreaks neatly inside window
    return "\n" + text.gsub(/(.{1,#{self.maxx}})( +|$\n?)|(.{1,#{self.maxx}})/, "\\1\\3\n")
  end
  alias :puts :p
end

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
  when '?' # Show helptext in right window 
    # Add code to show help text here
  when 'UP' # Examples of moving up and down in a window
    @index = @index <= @min_index ? @max_index : @index - 1
  when 'DOWN'
    @index = @index >= @max_index ? @min_index : @index + 1
  when 'PgUP'
    @index -= @w_l.maxy - 2
    @index = @min_index if @index < @min_index
  when 'PgDOWN'
    @index += @w_l.maxy - 2
    @index = @max_index if @index > @max_index
  when 'HOME'
    @index = @min_index
  when 'END'
    @index = @max_index
  when 'l'
    # ...etc
  when 'r'
    @break = true
  when 'q' # Exit 
    exit 0
  when '@' # Enter "Ruby debug"
    cmd = w_b_getstr("◆ ", "")
    @w_b.clr
    @w_b.refresh
    @w_b.update = true
    @w_r.clr
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
    end
    #@w_b.update = false
  end
  while STDIN.ready?
    chr = STDIN.getc
  end
end

# TOP WINDOW FUNCTIONS 

# BOTTOM WINDOW FUNCTIONS 
def w_b(info) # SHOW INFO IN @W_B
  @w_b.clr
  info      = "Choose window: i=IMDB list (+/- to add/remove from My list), g=Genres (+/- to add/remove), m=My list. " if info == nil
  info      = info[1..(@w_b.maxx - 3)] + "…" if info.length + 3 > @w_b.maxx 
  info     += " " * (@w_b.maxx - info.length) if info.length < @w_b.maxx
  @w_b.p(info)
  @w_b.update = false
end
def w_b_getstr(pretext, text) # A SIMPLE READLINE-LIKE ROUTINE
  Curses.curs_set(1)
  Curses.echo
  stk = 0
  pos = text.length
  chr = ""
  while chr != "ENTER"
    @w_b.setpos(0,0)
    text = pretext + text
    text += " " * (@w_b.maxx - text.length) if text.length < @w_b.maxx
    @w_b.p(text)
    @w_b.setpos(0,pretext.length + pos)
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
  Curses.curs_set(0)
  Curses.noecho
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
    @w_l.fg, @w_l.bg, @w_l.attr =  46, 234, 0
    @w_r.fg, @w_r.bg, @w_r.attr = 202, 235, 0
    loop do # INNER, CORE LOOP 
      @w_t.fill; @w_b.fill; @w_l.fill; @w_r.fill

      # Example code to write to the panes in various ways
      @w_t.p("Top window")
      @w_b.p("Bottom window")
      @w_l.p(196,182,Curses::A_BOLD,"Left window")
      @w_r.p("Right window")
      
      # Top window (info line) 
      
      # Bottom window (command line)

      # Left window

      # Right window

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
