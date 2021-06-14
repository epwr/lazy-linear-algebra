#!/usr/bin/ruby
#
# Author: Eric Power

# IMPORTS
# require_relative "./"

# SETTINGS
$config = {
	"do_not_overwrite_files" => true,  # If true, ensure that output_filename does not already exist.
	"input_filename" => nil,  # The filename of the code to look at (and generate unit tests for).
	"output_filename" => nil,  # The filename for the output (unit test code)
	"ifp" => nil,  # The input file pointer
	"ofp" => nil  # The output file pointer
}

# run
#
# Run the main control flow. Allows calling functions defined later on in the file.
def run

	# PROCESS ARGV
	if ARGV.include? "-h" or ARGV.include? "--help"
		print_help
		exit
	elsif ARGV.include? "-f"
		$config["do_not_overwrite_files"] = false
	end
	for arg in ARGV
		if ["-h", "--help", "-f"].include? arg # Ignore flags 
			next
		end

		# Grab filenames.
		if not $config["input_filename"]
			$config["input_filename"] = arg
			if not File.exists? $config["input_filename"]
				puts "ERROR: Input file does not exist."
				exit
			end
		elsif not $config["output_filename"]
			$config["output_filename"] = arg
			if $config["do_not_overwrite_files"]
				# Check if output file exists, if yes: raise error.
				if File.exists? $config["output_filename"]
					puts "ERROR: Output file exists."
					exit
				end
			end
		else
			puts "ERROR: Too many arguments given. Use -h flag for help."
			exit
		end
	end

	# Check that all needed config variables have been set.
	if not $config["output_filename"]
		puts "ERROR: No output file indicated. Use -h flag for help."
		exit
	end

	# CONTROL FLOW
	setup_file_pointers
	print_output_file_header
	create_unit_test_per_function
	print_output_file_footer

end

# setup_file_pointers
#
# Creates the input and output file pointers (and stores them in the global config hash).
def setup_file_pointers
	$config["ifp"] = File.new($config["input_filename"], "r")
	$config["ofp"] = File.new($config["output_filename"], "w")
end

# print_output_file_header
#
# Prints out the first few lines 
def print_output_file_header
	$config["ofp"].write( "#!/usr/bin/ruby\n#\n# Author: Eric Power\n#\n" )
	$config["ofp"].write( "# Description:\n#\tUnit Tests for #{$config["input_filename"]}\n\n" )
	$config["ofp"].write( "require_relative \"#{$config["input_filename"]}\"\n\n" )
	$config["ofp"].write( "$tests_passed = 0\n" )
	$config["ofp"].write( "$config = {\n\t\"exit_on_failure\" => true\n}\n\n" )
	$config["ofp"].write( "######################################################\n#                        TESTS                       #\n######################################################\n\n" )
	$config["ofp"].write( "def run_tests\n\n" )
end


# create_unit_test_per_function
#
#
def create_unit_test_per_function
	
	for line in $config["ifp"]
		if line =~ /class /
			if line =~ /</ # If a subclass
				is_subclass = true  # Can eventually add functionality to add unit tests for inherited methods.
				class_name = line.match /class (.*) </
			else
				is_subclass = false
				class_name = line.match /class (.*)$/
			end
			parse_class_methods class_name[1]
		elsif line =~ /def /
			function_call = line.match /def (.*)$/
			$config["ofp"].write( "\t#test(\"#{function_call[1]} 1\", #{function_call[1]}, EXPECTED)\n" )
			$config["ofp"].write( "\t#test(\"#{function_call[1]} 2\", #{function_call[1]}, EXPECTED)\n" )
			$config["ofp"].write( "\t#test(\"#{function_call[1]} 3\", #{function_call[1]}, EXPECTED)\n\n" )
		end
	end
end


# parse_class_methods
#
#
def parse_class_methods(class_name)

	$config["ofp"].write( "\n\t# Testing Class: #{class_name}\n" )
	$config["ofp"].write( "\t#@#{class_name}_obj = #{class_name}.new()  # TODO: Add needed parameters.\n\n" )

	open_count = 1
	for line in $config["ifp"]
		if line.match /^\s*if\W/ or line.match /^\s*for\W/ or line.match /^\s*while\W/ or line.match /^\s*case\W/ or line.match /^\s*begin\W/
			open_count += 1
		elsif line =~ /def /
			open_count += 1
			method_call = line.match /def (.*)$/
			$config["ofp"].write( "\t#test(\"#{class_name} > #{method_call[1]} 1\", @#{class_name}_obj.#{method_call[1]}, EXPECTED)\n" )
			$config["ofp"].write( "\t#test(\"#{class_name} > #{method_call[1]} 2\", @#{class_name}_obj.#{method_call[1]}, EXPECTED)\n" )
			$config["ofp"].write( "\t#test(\"#{class_name} > #{method_call[1]} 3\", @#{class_name}_obj.#{method_call[1]}, EXPECTED)\n\n" )
		elsif line.match /^\s*end\W/
			open_count -= 1
			if open_count == 0
				break  # Out of class definition.
			end
		end
	end
	$config["ofp"].write( "\n\n" )
end


# print_output_file_footer
#
#
def print_output_file_footer
	$config["ofp"].write( "\nend\n\n" )
	$config["ofp"].write( "######################################################\n#                  TESTING FUNCTION                  #\n######################################################\n\n" )
	$config["ofp"].write( "def test( test_name, output, expected_output)\n\n\tif output != expected_output\n\t\tputs \"TEST FAILED: #\{test_name\}\"\n\t\tputs \"\\tResult:   #\{output\}\"\n\t\tputs \"\\tExpected: #\{expected_output\}\"\n\t\tif $config[\"exit_on_failure\"]\n\t\t\texit\n\t\tend\n\telse\n\t\t$tests_passed += 1\n\tend\nend\n\n" )
	$config["ofp"].write( "######################################################\n#                      RUN TESTS                     #\n######################################################\n\n" )
	$config["ofp"].write( "run_tests" )
	$config["ofp"].write( "\nputs \"NUMBER OF TESTS PASSED: #\{$tests_passed\}\"\n" )
end

# print_help
#
# Prints the help message
def print_help
	puts "Generates a structure for a unit test file that has high code coverage."
	puts "usage: [flags] [code.rb] [output.rb]"
	puts ""
	puts "Flags:"
	puts "	-h		: Prints this help message."
	puts "	-f		: Forces the program to overwrite the output file (does not check if it exists)."
end

# The last line.
run
