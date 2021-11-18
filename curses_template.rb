#!/usr/bin/env ruby
# encoding: utf-8

# This is a basic template for my Curses applications. Feel free to use.
# 
# It is an example of a basic curses application with 4 windows like this:
#
# +-------------------------------+
# | @w_t                          |
# +---------------+---------------+
# |               |               |
# | @w_l          | @w_r          |
# |               |               |
# |               |               |
# +---------------+---------------+
# | @w_b                          |
# +-------------------------------+

require 'io/console'
require 'curses'
include  Curses

Curses.init_screen
Curses.start_color
Curses.curs_set(0)
Curses.noecho
Curses.cbreak
Curses.stdscr.keypad = true

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
  def fill_from_cur_pos # Fills the rest of the window from current line
    x = self.curx
    y = self.cury
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
  def pclr(text) # Puts text to window and clears the rest of the window
    self.p(text)
    self.clr_from_cur_line
  end
  def paclr(fg, bg, attr, text) # Puts text to window with full set of attributes and clears rest of window
    self.paclr(fg, bg, attr, text)
    self.clr_from_cur_line
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

def getchr # PROCESS KEY PRESSES
  c = STDIN.getch(min: 0, time: 0.1)
  case c
  when "\e"    # ANSI escape sequences
    case $stdin.getc
    when '['   # CSI
      case $stdin.getc
      when 'A' then chr = "UP"
      when 'B' then chr = "DOWN"
      when 'C' then chr = "RIGHT"
      when 'D' then chr = "LEFT"
      when 'Z' then chr = "S-TAB"
      when '2' then chr = "INS"    ; STDIN.getc
      when '3' then chr = "DEL"    ; STDIN.getc
      when '5' then chr = "PgUP"   ; STDIN.getc
      when '6' then chr = "PgDOWN" ; STDIN.getc
      when '7' then chr = "HOME"   ; STDIN.getc
      when '8' then chr = "END"    ; STDIN.getc
      end
    end
  when "", "" then chr = "BACK"
  when "" then chr = "WBACK"
  when "" then chr = "LDEL"
  when "" then chr = "C-T"
  when "\r" then chr = "ENTER"
  when "\t" then chr = "TAB"
  when /./  then chr = c
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
  end
end

# TOP WINDOW FUNCTIONS 

# BOTTOM WINDOW FUNCTIONS 

# LEFT WINDOW FUNCTIONS

# RIGHT WINDOW FUNCTIONS 


# MAIN PROGRAM 
loop do # OUTER LOOP - (catching refreshes via 'r')
  @break = false # Initialize @break variable (set if user hits 'r')
  begin # Create the four windows/panels 
    maxx = Curses.cols
    exit if maxx < @w_l_width
    maxy = Curses.lines
    # Curses::Window.new(h,w,y,x)
    @w_t = Curses::Window.new(1, maxx, 0, 0)
    @w_b = Curses::Window.new(1, maxx, maxy - 1, 0)
    @w_l = Curses::Window.new(maxy - 2, maxx / 2, 1, 0)
    @w_r = Curses::Window.new(maxy - 2, maxx / 2, 1, maxx / 2)
    loop do # INNER, CORE LOOP 
      # Top window (info line) 
      
      # Bottom window (command line)

      # Left window

      # Right window

      main_getkey        # Get key from user 

      break if @break    # Break to outer loop, redrawing windows, if user hit 'r'
      break if Curses.cols != maxx or Curses.lines != maxy # break on terminal resize 
    end
  ensure # On exit: close curses, clear terminal 
    close_screen
  end
end

# vim: set sw=2 sts=2 et fdm=syntax fdn=2 fcs=fold\:\ :
