#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Provides the funcitonality to parse a TokenStream into an Abstract Syntax Tree - assuming
#    the token stream is syntactically correct. 

$VERBOSE = nil  # Turn off pattern matching warnings.
# IMPORTS
require_relative "./core/lexer.rb"
require_relative "./core/parser.rb"
require_relative "./core/interpreter.rb"
$VERBOSE = false  # Turn warnings back to default.


# DEFAULT 'INCLUDE' FILES


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                   PROCESS COMMAND LINE ARGS                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

$config = { 
	"output_type" => "normal", 
	"verbose" => false, 
	"input_filename" => nil,
	"mode" => "normal"
}


# run
#
# Run the main control flow. Allows calling functions defined later on in the file.
def run

	# PROCESS ARGV
	if ARGV.include? "-h" or ARGV.include? "--help"
		print_help
		exit
	end
	if ARGV.include? "-v"
		$config["verbose"] = true
	end
	if ARGV.include? "-i"
		$config["mode"] = "interactive"
	end
	for arg in ARGV
		if ["-h", "--help", "-v", "-i"].include? arg # Ignore flags 
			next
		end

		# Grab filename.
		if not $config["input_filename"]
			$config["input_filename"] = arg
		else
			puts "REPL ERROR: Currently, this only supports running a single file."
			exit
		end

		if not File.exists? $config["input_filename"]
			puts "REPL ERROR: Input file '#{$config["input_filename"]} does not exist."
			exit
		end
	end

	# Check that all needed config variables have been set.
	if not $config["input_filename"] and $config["mode"] == "normal"
		puts "REPL ERROR: No input file indicated. Use -h flag for help."
		exit
	end

	# CONTROL FLOW
	if $config["mode"] == "normal"
		parser = Parser.new TokenStream.new $config["input_filename"]
		program = parser.run
		eval_program(program)
	elsif $config["mode"] == "interactive"

		env = {}
		stack_trace = []

		if $config["input_filename"]
			parser = Parser.new TokenStream.new $config["input_filename"]
			program = parser.run
			_, env = eval_program(program)
			if env == nil  # error occured in eval_program.
				puts "Interactive mode running with an empty environment."
				env = {}
			end
		end

		int_token = InteractiveTokenStream.new
		int_parser = Parser.new int_token
		while int_token.peak
			begin
				node = int_parser.parse_next
			rescue => e
				puts e.message
				next
			end

			begin
				value, env = eval_program_under([node], env, stack_trace)
				print_on_terminal(value)
			rescue => e
				puts e.message
			end
		end
	end

end

# print_help
#
# Prints the help message
def print_help
	puts "Parses and runs a program in the PL programming language."
	puts "usage: [flags] [input_file]"
	puts ""
	puts "Flags:"
	puts "	-h		: Prints this help message."
	puts "	-v		: Runs this program in verbose mode (not yet implemented)."
	puts "  -i      : Runs in interactive mode (after running a file, if provided)."
end

# The last line.
run



