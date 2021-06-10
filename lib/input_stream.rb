#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Classes that serve as a stream of characters. Abstracting this away slightly to allow the
#    tokenize to ignore the difference between reading from a file, and reading from stdin.

class CharacterStream

	def initialize filename
		@char_stream = File.new(filename, "r")  # if File::exists?(filename)
		@next_char = nil
		@cur_line = 1
		@cur_col  = 1
	end

	def peak
		if @next_char == nil 
			begin
				@next_char = @char_stream.sysread(1)
			rescue EOFError
				return nil
			end
		else
			@next_char
		end
	end

	def next
		if @next_char == nil 
			char = @char_stream.sysread(1)
		else
			char =  @next_char
			@next_char = nil
		end
		if char == "\n"
			@cur_line += 1
			@cur_col = 1
		else
			@cur_col += 1
		end
		char
	end

	def eof?
		 self.peak != nil
	end

	def whoops msg
		# TODO: Raises an 'error'
		puts "ERROR (#{@cur_line}:#{@cur_col}): #{msg}"
	end
	
	def get_cur_line
		@cur_line
	end

	def get_cur_col
		@cur_col
	end
	
end