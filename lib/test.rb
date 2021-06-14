#!/usr/bin/ruby
#
# Author: Eric Power

require_relative "./lexer.rb"
require_relative "./parser.rb"
require_relative "./interpreter.rb"


def test_lexer 
	lxr = TokenStream.new 'manual_test_files/garbage.pl'
	
	token = lxr.next
	puts "Token: #{token}"
	while token
		token = lxr.next
		puts "Token: #{tokenvars = splitter("(", ")", ",")}"
	end
end

def test_parser

	parser = Parser.new TokenStream.new 'manual_test_files/small_test.pl'
	parser.run

end

def test_interpreter

	parser = Parser.new TokenStream.new 'manual_test_files/small_test.pl'
	program = parser.run
	eval_program(program)

end

# RUN TESTS

#test_parser
test_interpreter

