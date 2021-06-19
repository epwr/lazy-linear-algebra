#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Classes that serve as a stream of characters. Abstracting this away slightly to allow the
#    lexer to ignore the difference between reading from a file, and reading from stdin.
#
# 	 Classes:
#        => CharacterStream
#              The main class. Provides the ability to get or check the next character.
#        => InteractiveCharacterStream
#              Subclass of CharacterStream. Used when reading a file from STDIN (eg. in a REPL)


# CharacterStream
#
# Allows handling a file as a stream of characters. Provides:
# => next
# 		Removes/eats and returns the first character in the stream.
# => peak
# 		Returns (but does not remove/eat) the character in the stream.
# => eof?
# 		Returns whether or not the stream has reached the EOF.
# => get_cur_line
# 		Returns the line of the first character in the stream.
# => get_cur_col
# 		Returns the cols of the first character in the stream.
class CharacterStream

	def initialize filename
		@char_stream = File.new(filename, "r")  # if File::exists?(filename)
		@next_char = nil
		@cur_line = 1
		@cur_col  = 1
	end

	# peak
	#
	# Shows the next letter but keeps it on the 'stack' of letters. Returns nil if
	# at the end of the file.
	def peak
		if @next_char == nil 
			begin
				@next_char = self.read_next_char
			rescue EOFError
				return nil
			end
		else
			@next_char
		end
	end

	# next
	#
	# Returns the next letter (and removes it from the 'stack'). Throws an
	# EOFError if at the EOF.
	def next
		if @next_char == nil 
			char = self.read_next_char
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


	# eof?
	#
	# Returns whether or not there are more characters in the stream
	def eof?
		 self.peak != nil
	end
	

	# get_cur_line
	#
	# Returns @cur_line. Should be an attr_reader method, but
	# that will wait for a refactor.
	def get_cur_line
		@cur_line
	end


	# get_cur_col
	#
	# Returns @cur_col. Should be an attr_reader method, but
	# that will wait for a refactor.
	def get_cur_col
		@cur_col
	end


	private
	# read_next_char (private)
	#
	# Reads the next character from the @char_stream. A method
	# to allow it to be overwritten in subclasses.
	def read_next_char
		@char_stream.sysread(1)
	end
	
end


# InteractiveCharacterStream
#
# Allows handling STDIN as a stream of characters. Provides:
# => next
# 		Removes/eats and returns the first character in the stream.
# => peak
# 		Returns (but does not remove/eat) the character in the stream.
# => eof?
# 		Returns whether or not the stream has reached the EOF.
# => get_cur_line
# 		Returns the line of the first character in the stream.
# => get_cur_col
# 		Returns the cols of the first character in the stream.
class InteractiveCharacterStream < CharacterStream

	def initialize
		@current_line = ""
		@next_char = nil
		@cur_line = 1
		@cur_col  = 1
	end

	private
	# read_next_char (private)
	#
	# Gets the next character from STDIN. Prompts the user for input if STDIN is
	# empty and an EOF has not been received.
	def read_next_char
		if @current_line == ""
			print ">> "
			@current_line = STDIN.gets
		end
		if @current_line
			char = @current_line[0]
			@current_line = @current_line[1..]
			return char
		else
			return nil
		end
	end

end