#!/usr/bin/ruby
#
# Author: Eric Power

require_relative "./lexer.rb"
require_relative "./parser.rb"
require_relative "./interpreter.rb"


def test_lexer 
	lxr = TokenStream.new 'test_files/garbage.pl'
	
	token = lxr.next
	puts "Token: #{token}"
	while token
		token = lxr.next
		puts "Token: #{tokenvars = splitter("(", ")", ",")}"
	end
end

def test_parser

	parser = Parser.new TokenStream.new 'test_files/tester.pl'
	parser.run

end

# RUN TESTS

program = test_parser
