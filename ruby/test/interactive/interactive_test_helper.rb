# ruby-nxt Control Mindstorms NXT via Bluetooth Serial Port Connection
# Copyright (C) 2006 Matt Zukowski <matt@roughest.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

begin
	require 'rubygems'
	require_gem "term-ansicolor"
	$COLOUR = true
rescue LoadError
	$COLOUR = false
	puts "Please install term-ansicolor gem to get colour output."
	puts "Colour output will be disabled..."
	puts
end

module InteractiveTestHelper
	def info(msg)
		msg = Term::ANSIColor.white(msg) if $COLOUR
		puts "#{msg}"
	end
	
	def notice(msg)
		msg = Term::ANSIColor.yellow(msg) if $COLOUR
		puts "#{msg}"
	end
	
	def prompt(msg)
		msg = Term::ANSIColor.cyan(msg) if $COLOUR
		puts "#{msg}"
		return gets
	end
	
	def pass(msg)
		msg = Term::ANSIColor.green(msg) if $COLOUR
		msg = Term::ANSIColor.bold(msg) if $COLOUR
		puts "#{msg}"
	end
	
	def fail(msg)
		msg = Term::ANSIColor.red(msg) if $COLOUR
		msg = Term::ANSIColor.red(msg) if $COLOUR
		puts "#{msg}"
	end

	def puts_sameline(msg)
		puts "#{msg}"
		puts "\e[2A"
	end
	
	def meter(value, label = "Level", threshold = nil, max = 100, min = 0)
		width = 40
		if value.nil?
			bars = "?" * width
			spaces = ""
			percent_formatted = " ??? "
		else
			if value >= max
				percent = 1.0
	    else
	    	percent = ((value - min) / max.to_f)
	    end
			bars = "|" * (percent * width)
			spaces = " " * ((1 - percent) * width)
		
			percent_formatted = "%5.1f" % (percent * 100)
		end
		meterbar = bars + spaces
		
		if threshold
			threshold_pos = (((threshold - min) / max.to_f) * 40).to_i
			meterbar[threshold_pos] = "!"
		end
		
		puts_sameline " #{label}: (#{percent_formatted}%) [#{min}]#{meterbar}[#{max}]"
	end

end