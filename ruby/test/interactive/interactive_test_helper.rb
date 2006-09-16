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

	def puts_sameline(msg)
		puts "#{msg}"
		puts "\e[2A"
	end
	
	def meter(value, label = "Level", threshold = nil, max = 1.0, min = 0)
		width = 40
		if value >= max
			percent = 1.0
    else
    	percent = ((value - min) / max.to_f)
    end
		bars = "|" * (percent * width)
		spaces = " " * ((1 - percent) * width)
		meterbar = bars + spaces
		
		if threshold
			threshold_pos = (((threshold - min) / max.to_f) * 40).to_i
			meterbar[threshold_pos] = "!"
		end
		
		percent_formatted = "%5.1f" % (percent * 100)
		
		puts_sameline " #{label}: (#{percent_formatted}%) [#{min}]#{meterbar}[#{max}]"
	end

end