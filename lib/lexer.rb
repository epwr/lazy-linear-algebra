#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Returns tokens, which have a type and a value. 

require_relative "./input_stream.rb"

class Token

	attr_reader :type, :value, :line, :col
	def initialize(type, value, line, column)
		@type 	= type
		@value 	= value
		@line 	= line
		@col 	= column
	end

	def to_s
		"(#{@type} : '#{@value}')"
	end
end


class TokenStream

	@@comment_start 		  = "#"
	@@whitespace 			  = [" ", "\t", "\n", "\r"]  # TODO: is \n whitespace or punctuation?

	@@allowed_digit 		  = ["0", "1", "2", "3", "4", "5", "6", "7","8", "9", "."]  
	@@allowed_digit_start	  = ["0", "1", "2", "3", "4", "5", "6", "7","8", "9"]  
	@@allowed_id 			  = ["_", "-", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
	@@allowed_id_start 		  = ["_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	@@allowed_operator 		  = ["=", "+", "-", "*", "/", ">", "<", "?", "|", "`", "!"]
	@@allowed_punctuation	  = ["(", ")", "[", "]", "{", "}", ".", ",", ";" ]

	@@allowed_keywords		  = ["if", "then", "else", "end", "true", "false", "lambda", "return", "set"]

	def initialize filename

		@chars = CharacterStream.new filename
		@next_token = nil

	end

	def next
		if @next_token
			token = @next_token
			@next_token = nil
			return token
		else
			return read_token
		end
	end

	def peak
		if not @next_token
			@next_token = read_token
		end
		return @next_token
	end

	def eof?
		not peak
	end

	def whoops msg
		# TODO: Should the error be thrown at the start of the most recent token?
		@chars.whoops msg
	end

	def is_end_of_line?
		# Finds out if another token exists on this line 
		#     => used in matrices to separate rows
		#     => used in look ahead parsing to stop at newlines.
		while true
			begin
				char =  @chars.peak
			rescue EOFError
		 		return nil
		 	end

		 	if not (@@whitespace - ["\n"]).include? char
		 		break
		 	end
		 	char = @chars.next
		end
		return (char == "\n" or char == @@comment_start)
	end

	private

	def read_token

		# Find the start of the next token
		char = read_whitespace
		if char == nil
			return nil
		elsif char == @@comment_start
			read_comment
			return read_token  
		end

		# Find and return token
		if char == '"' || char == "'"
			return read_string
		elsif is_digit char
			return read_digit
		elsif is_operator char
			return read_operator
		elsif is_punctuation char
			return read_punctuation
		elsif is_var_or_keyword char
			return read_var_or_keyword
		else
			@chars.whoops("Character not recognized: #{char}")
		end
	end

	# TOKEN METHODS - is_xxx methods

	def is_operator char
		@@allowed_operator.include? char
	end

	def is_digit char
		@@allowed_digit_start.include? char
	end

	def is_punctuation char
		@@allowed_punctuation.include? char
	end

	def is_var_or_keyword char
		@@allowed_id_start.include? char
	end

	# TOKEN METHODS - read_xxx methods

	def read_string
		
		# TODO: Add the ability to have escape characters.
		start_char 	= @chars.next  # Don't add quotation marks to the string value
		line_num 	= @chars.get_cur_line
		col_num  	= @chars.get_cur_col
		tok_val 	= ''

		while true
			begin
				char = @chars.peak
			rescue EOFError
				raise ParsingError "ERROR: At line: #{line_num}, col: #{col_num} >> String does not end."
		 		return nil
		 	end

		 	if char == start_char
		 		return Token.new("String", tok_val, line_num, col_num)
		 	end
		 	tok_val += char
		 	@chars.next
		end
	end

	def read_digit

		line_num 	= @chars.get_cur_line
		col_num  	= @chars.get_cur_col
		tok_val 	= @chars.next  

		while true
			begin
				char = @chars.peak
			rescue EOFError
				char = nil  # Will make the token be returned as read.
		 	end

		 	if not @@allowed_digit.include? char
		 		return Token.new("Digit", tok_val, line_num, col_num)
		 	end
		 	tok_val += char
		 	@chars.next
		end
	end

	def read_operator

		line_num 	= @chars.get_cur_line
		col_num  	= @chars.get_cur_col
		tok_val 	= ''


		while true
			begin
				char = @chars.peak
			rescue EOFError
				char = nil  # Will make the token be returned as read.
		 	end

		 	if not is_operator char
		 		return Token.new("Operator", tok_val, line_num, col_num)
		 	end
		 	tok_val += char
		 	@chars.next
		end
	end

	def read_punctuation
		return Token.new("Punctuation", @chars.next, @chars.get_cur_line, @chars.get_cur_col)
	end

	def read_var_or_keyword

		line_num 	= @chars.get_cur_line
		col_num  	= @chars.get_cur_col
		tok_val 	= ''

		while true
			begin
				char = @chars.peak
			rescue EOFError
				char = nil  # Will make the token be returned as read.
		 	end

		 	if not @@allowed_id.include? char
		 		if @@allowed_keywords.include? tok_val
		 			return Token.new("Keyword", tok_val, line_num, col_num)
		 		else
		 			return Token.new("Identifier", tok_val, line_num, col_num)
		 		end
		 	end
		 	tok_val += char  # TODO: move @chars.next to this line.
		 	@chars.next
		end
	end




	# READING METHODS

	def read_whitespace
		while true
			begin
				char =  @chars.peak
			rescue EOFError
		 		return nil
		 	end

		 	if not @@whitespace.include? char
		 		return @chars.peak
		 	end
		 	char = @chars.next
		end
	end

	def read_comment
		while true
			begin
				char =  @chars.peak
			rescue EOFError
		 		return nil
		 	end

		 	if char == "\n"
		 		@chars.next
		 		return @chars.peak
		 	end
		 	char = @chars.next
		end
	end


end