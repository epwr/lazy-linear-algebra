#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Provides the funcitonality to parse a TokenStream into an Abstract Syntax Tree - assuming
#    the token stream is syntactically correct. 

require_relative "./parser/lexer.rb"
require_relative "./parser/parser.rb"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                   PROCESS COMMAND LINE ARGS                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

_config = { 
	"output_type" => "normal", 
	"verbose_output" => false, 
	"filenames" => []
}

def print_help
	puts ""
end

ARGV.each {|x| 
	case x
	when /^-/
		x[1..].each_char {|f|
			puts "printing flag: #{f}"
			case f
			when "l" then _config["output_type"] = "latex"
			when "m" then _config["output_type"] = "math_jax"				
			when "v" then _config["verbose_output"] = true
			when "h" then print_help
			end
		}
	else
		_config["filenames"].append(x)
	end
}



