#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#	Unit Tests for ../interpreter.rb

require_relative "../interpreter.rb"

$tests_passed = 0
$config = {
	"exit_on_failure" => true
}

######################################################
#                        TESTS                       #
######################################################

def run_tests

	term0 = Term.new(__LINE__,10, magnitude:  0, imaginary: true) 
	term1 = Term.new(__LINE__,10, magnitude:  3)
	term2 = Term.new(__LINE__,10, magnitude: -2)
	term3 = Term.new(__LINE__,10, magnitude:  1)
	term4 = Term.new(__LINE__,10, magnitude: -1, imaginary: true)
	term5 = Term.new(__LINE__,10, magnitude: -2, imaginary: true)
	term6 = Term.new(__LINE__,10, magnitude:  3, literal_variable: "a")
	term7 = Term.new(__LINE__,10, magnitude:  2, literal_variable: "b")
	term8 = Term.new(__LINE__,10, magnitude: -1, literal_variable: "a")
	term9 = Term.new(__LINE__,10, magnitude:  1, imaginary: true, literal_variable: "b")

	tl1 = TermList.new(__LINE__, 5, [term1, term4])
	tl2 = TermList.new(__LINE__, 5, [term6, term3])
	tl3 = TermList.new(__LINE__, 5, [term7, term9, term2])

	
	

	#test("eval_program(program) 1", eval_program(program), EXPECTED)
	#test("eval_program(program) 2", eval_program(program), EXPECTED)
	#test("eval_program(program) 3", eval_program(program), EXPECTED)

	#test("eval_node_under(node, env, stack_trace) 1", eval_node_under(node, env, stack_trace), EXPECTED)
	#test("eval_node_under(node, env, stack_trace) 2", eval_node_under(node, env, stack_trace), EXPECTED)
	#test("eval_node_under(node, env, stack_trace) 3", eval_node_under(node, env, stack_trace), EXPECTED)

	#test("eval_program_under(program, env, stack_trace) 1", eval_program_under(program, env, stack_trace), EXPECTED)
	#test("eval_program_under(program, env, stack_trace) 2", eval_program_under(program, env, stack_trace), EXPECTED)
	#test("eval_program_under(program, env, stack_trace) 3", eval_program_under(program, env, stack_trace), EXPECTED)

	#test("eval_operation(node, env, stack_trace) 1", eval_operation(node, env, stack_trace), EXPECTED)
	#test("eval_operation(node, env, stack_trace) 2", eval_operation(node, env, stack_trace), EXPECTED)
	#test("eval_operation(node, env, stack_trace) 3", eval_operation(node, env, stack_trace), EXPECTED)

	#test("eval_unary_operation(node, env, stack_trace) 1", eval_unary_operation(node, env, stack_trace), EXPECTED)
	#test("eval_unary_operation(node, env, stack_trace) 2", eval_unary_operation(node, env, stack_trace), EXPECTED)
	#test("eval_unary_operation(node, env, stack_trace) 3", eval_unary_operation(node, env, stack_trace), EXPECTED)

	#test("eval_if_then_else(node, env, stack_trace) 1", eval_if_then_else(node, env, stack_trace), EXPECTED)
	#test("eval_if_then_else(node, env, stack_trace) 2", eval_if_then_else(node, env, stack_trace), EXPECTED)
	#test("eval_if_then_else(node, env, stack_trace) 3", eval_if_then_else(node, env, stack_trace), EXPECTED)

	#test("eval_call(node, env, stack_trace) 1", eval_call(node, env, stack_trace), EXPECTED)
	#test("eval_call(node, env, stack_trace) 2", eval_call(node, env, stack_trace), EXPECTED)
	#test("eval_call(node, env, stack_trace) 3", eval_call(node, env, stack_trace), EXPECTED)

	#test("eval_tuple(node, env, stack_trace) 1", eval_tuple(node, env, stack_trace), EXPECTED)
	#test("eval_tuple(node, env, stack_trace) 2", eval_tuple(node, env, stack_trace), EXPECTED)
	#test("eval_tuple(node, env, stack_trace) 3", eval_tuple(node, env, stack_trace), EXPECTED)

	#test("add_fraction_and_fraction(frac1, frac2) 1", add_fraction_and_fraction(frac1, frac2), EXPECTED)
	#test("add_fraction_and_fraction(frac1, frac2) 2", add_fraction_and_fraction(frac1, frac2), EXPECTED)
	#test("add_fraction_and_fraction(frac1, frac2) 3", add_fraction_and_fraction(frac1, frac2), EXPECTED)

	#test("add_fraction_and_term_list(fraction, term_list) 1", add_fraction_and_term_list(fraction, term_list), EXPECTED)
	#test("add_fraction_and_term_list(fraction, term_list) 2", add_fraction_and_term_list(fraction, term_list), EXPECTED)
	#test("add_fraction_and_term_list(fraction, term_list) 3", add_fraction_and_term_list(fraction, term_list), EXPECTED)

	#test("add_fraction_and_term(fraction, term) 1", add_fraction_and_term(fraction, term), EXPECTED)
	#test("add_fraction_and_term(fraction, term) 2", add_fraction_and_term(fraction, term), EXPECTED)
	#test("add_fraction_and_term(fraction, term) 3", add_fraction_and_term(fraction, term), EXPECTED)

	test("add_two_terms(left, right) 1", add_two_terms(term1, term2), term3)
	test("add_two_terms(left, right) 2", add_two_terms(term2, term1), term3)
	test("add_two_terms(left, right) 3", add_two_terms(term4, term4), term5)

	#test("add_term_and_term_list(term, term_list) 1", add_term_and_term_list(term, term_list), EXPECTED)
	#test("add_term_and_term_list(term, term_list) 2", add_term_and_term_list(term, term_list), EXPECTED)
	#test("add_term_and_term_list(term, term_list) 3", add_term_and_term_list(term, term_list), EXPECTED)

	#test("add_term_list_and_term_list(tl_left, tl_right) 1", add_term_list_and_term_list(tl_left, tl_right), EXPECTED)
	#test("add_term_list_and_term_list(tl_left, tl_right) 2", add_term_list_and_term_list(tl_left, tl_right), EXPECTED)
	#test("add_term_list_and_term_list(tl_left, tl_right) 3", add_term_list_and_term_list(tl_left, tl_right), EXPECTED)

	#test("add_unknown_terms_or_term_lists(left, right) 1", add_unknown_terms_or_term_lists(left, right), EXPECTED)
	#test("add_unknown_terms_or_term_lists(left, right) 2", add_unknown_terms_or_term_lists(left, right), EXPECTED)
	#test("add_unknown_terms_or_term_lists(left, right) 3", add_unknown_terms_or_term_lists(left, right), EXPECTED)

	#test("divide_fraction_by_fraction(frac1, frac2) 1", divide_fraction_by_fraction(frac1, frac2), EXPECTED)
	#test("divide_fraction_by_fraction(frac1, frac2) 2", divide_fraction_by_fraction(frac1, frac2), EXPECTED)
	#test("divide_fraction_by_fraction(frac1, frac2) 3", divide_fraction_by_fraction(frac1, frac2), EXPECTED)

	#test("divide_fraction_by_term_list(fraction, term_list) 1", divide_fraction_by_term_list(fraction, term_list), EXPECTED)
	#test("divide_fraction_by_term_list(fraction, term_list) 2", divide_fraction_by_term_list(fraction, term_list), EXPECTED)
	#test("divide_fraction_by_term_list(fraction, term_list) 3", divide_fraction_by_term_list(fraction, term_list), EXPECTED)

	#test("divide_fraction_by_term(fraction, term) 1", divide_fraction_by_term(fraction, term), EXPECTED)
	#test("divide_fraction_by_term(fraction, term) 2", divide_fraction_by_term(fraction, term), EXPECTED)
	#test("divide_fraction_by_term(fraction, term) 3", divide_fraction_by_term(fraction, term), EXPECTED)

	#test("divide_term_list_by_fraction 1", divide_term_list_by_fraction, EXPECTED)
	#test("divide_term_list_by_fraction 2", divide_term_list_by_fraction, EXPECTED)
	#test("divide_term_list_by_fraction 3", divide_term_list_by_fraction, EXPECTED)

	#test("divide_term_by_fraction(term, fraction) 1", divide_term_by_fraction(term, fraction), EXPECTED)
	#test("divide_term_by_fraction(term, fraction) 2", divide_term_by_fraction(term, fraction), EXPECTED)
	#test("divide_term_by_fraction(term, fraction) 3", divide_term_by_fraction(term, fraction), EXPECTED)

	#test("divide_two_terms(left, right) 1", divide_two_terms(left, right), EXPECTED)
	#test("divide_two_terms(left, right) 2", divide_two_terms(left, right), EXPECTED)
	#test("divide_two_terms(left, right) 3", divide_two_terms(left, right), EXPECTED)

	#test("divide_term_by_term_list(term, term_list) 1", divide_term_by_term_list(term, term_list), EXPECTED)
	#test("divide_term_by_term_list(term, term_list) 2", divide_term_by_term_list(term, term_list), EXPECTED)
	#test("divide_term_by_term_list(term, term_list) 3", divide_term_by_term_list(term, term_list), EXPECTED)

	#test("divide_term_list_by_term(term_list, term) 1", divide_term_list_by_term(term_list, term), EXPECTED)
	#test("divide_term_list_by_term(term_list, term) 2", divide_term_list_by_term(term_list, term), EXPECTED)
	#test("divide_term_list_by_term(term_list, term) 3", divide_term_list_by_term(term_list, term), EXPECTED)

	#test("divide_term_list_by_term_list(tl_left, tl_right) 1", divide_term_list_by_term_list(tl_left, tl_right), EXPECTED)
	#test("divide_term_list_by_term_list(tl_left, tl_right) 2", divide_term_list_by_term_list(tl_left, tl_right), EXPECTED)
	#test("divide_term_list_by_term_list(tl_left, tl_right) 3", divide_term_list_by_term_list(tl_left, tl_right), EXPECTED)

	#test("invert_fraction fraction 1", invert_fraction fraction, EXPECTED)
	#test("invert_fraction fraction 2", invert_fraction fraction, EXPECTED)
	#test("invert_fraction fraction 3", invert_fraction fraction, EXPECTED)

	#test("flip_sign_on_term term 1", flip_sign_on_term term, EXPECTED)
	#test("flip_sign_on_term term 2", flip_sign_on_term term, EXPECTED)
	#test("flip_sign_on_term term 3", flip_sign_on_term term, EXPECTED)

	#test("flip_sign_on_term_list term_list 1", flip_sign_on_term_list term_list, EXPECTED)
	#test("flip_sign_on_term_list term_list 2", flip_sign_on_term_list term_list, EXPECTED)
	#test("flip_sign_on_term_list term_list 3", flip_sign_on_term_list term_list, EXPECTED)

	#test("flip_sign_on_fraction fraction 1", flip_sign_on_fraction fraction, EXPECTED)
	#test("flip_sign_on_fraction fraction 2", flip_sign_on_fraction fraction, EXPECTED)
	#test("flip_sign_on_fraction fraction 3", flip_sign_on_fraction fraction, EXPECTED)

	#test("multiply_fraction_and_fraction(left, right) 1", multiply_fraction_and_fraction(left, right), EXPECTED)
	#test("multiply_fraction_and_fraction(left, right) 2", multiply_fraction_and_fraction(left, right), EXPECTED)
	#test("multiply_fraction_and_fraction(left, right) 3", multiply_fraction_and_fraction(left, right), EXPECTED)

	#test("multiply_fraction_and_term_list(fraction, term_list) 1", multiply_fraction_and_term_list(fraction, term_list), EXPECTED)
	#test("multiply_fraction_and_term_list(fraction, term_list) 2", multiply_fraction_and_term_list(fraction, term_list), EXPECTED)
	#test("multiply_fraction_and_term_list(fraction, term_list) 3", multiply_fraction_and_term_list(fraction, term_list), EXPECTED)

	#test("multiply_fraction_and_term(fraction, term) 1", multiply_fraction_and_term(fraction, term), EXPECTED)
	#test("multiply_fraction_and_term(fraction, term) 2", multiply_fraction_and_term(fraction, term), EXPECTED)
	#test("multiply_fraction_and_term(fraction, term) 3", multiply_fraction_and_term(fraction, term), EXPECTED)

	#test("multiply_two_terms(left, right) 1", multiply_two_terms(left, right), EXPECTED)
	#test("multiply_two_terms(left, right) 2", multiply_two_terms(left, right), EXPECTED)
	#test("multiply_two_terms(left, right) 3", multiply_two_terms(left, right), EXPECTED)

	#test("multiply_term_and_term_list(term, term_list) 1", multiply_term_and_term_list(term, term_list), EXPECTED)
	#test("multiply_term_and_term_list(term, term_list) 2", multiply_term_and_term_list(term, term_list), EXPECTED)
	#test("multiply_term_and_term_list(term, term_list) 3", multiply_term_and_term_list(term, term_list), EXPECTED)

	#test("multiply_term_list_and_term_list(tl_left, tl_right) 1", multiply_term_list_and_term_list(tl_left, tl_right), EXPECTED)
	#test("multiply_term_list_and_term_list(tl_left, tl_right) 2", multiply_term_list_and_term_list(tl_left, tl_right), EXPECTED)
	#test("multiply_term_list_and_term_list(tl_left, tl_right) 3", multiply_term_list_and_term_list(tl_left, tl_right), EXPECTED)

	#test("multiply_unknown_terms_or_term_lists(left, right) 1", multiply_unknown_terms_or_term_lists(left, right), EXPECTED)
	#test("multiply_unknown_terms_or_term_lists(left, right) 2", multiply_unknown_terms_or_term_lists(left, right), EXPECTED)
	#test("multiply_unknown_terms_or_term_lists(left, right) 3", multiply_unknown_terms_or_term_lists(left, right), EXPECTED)

	#test("subtract_fraction_from_fraction(frac1, frac2) 1", subtract_fraction_from_fraction(frac1, frac2), EXPECTED)
	#test("subtract_fraction_from_fraction(frac1, frac2) 2", subtract_fraction_from_fraction(frac1, frac2), EXPECTED)
	#test("subtract_fraction_from_fraction(frac1, frac2) 3", subtract_fraction_from_fraction(frac1, frac2), EXPECTED)

	#test("subtract_fraction_from_term_list(fraction, term_list) 1", subtract_fraction_from_term_list(fraction, term_list), EXPECTED)
	#test("subtract_fraction_from_term_list(fraction, term_list) 2", subtract_fraction_from_term_list(fraction, term_list), EXPECTED)
	#test("subtract_fraction_from_term_list(fraction, term_list) 3", subtract_fraction_from_term_list(fraction, term_list), EXPECTED)

	#test("subtract_fraction_from_term(fraction, term) 1", subtract_fraction_from_term(fraction, term), EXPECTED)
	#test("subtract_fraction_from_term(fraction, term) 2", subtract_fraction_from_term(fraction, term), EXPECTED)
	#test("subtract_fraction_from_term(fraction, term) 3", subtract_fraction_from_term(fraction, term), EXPECTED)

	#test("subtract_two_terms(left, right) 1", subtract_two_terms(left, right), EXPECTED)
	#test("subtract_two_terms(left, right) 2", subtract_two_terms(left, right), EXPECTED)
	#test("subtract_two_terms(left, right) 3", subtract_two_terms(left, right), EXPECTED)

	#test("subtract_term_from_fraction 1", subtract_term_from_fraction, EXPECTED)
	#test("subtract_term_from_fraction 2", subtract_term_from_fraction, EXPECTED)
	#test("subtract_term_from_fraction 3", subtract_term_from_fraction, EXPECTED)

	#test("subtract_term_from_term_list(term, term_list) 1", subtract_term_from_term_list(term, term_list), EXPECTED)
	#test("subtract_term_from_term_list(term, term_list) 2", subtract_term_from_term_list(term, term_list), EXPECTED)
	#test("subtract_term_from_term_list(term, term_list) 3", subtract_term_from_term_list(term, term_list), EXPECTED)

	#test("subtract_term_list_from_fraction 1", subtract_term_list_from_fraction, EXPECTED)
	#test("subtract_term_list_from_fraction 2", subtract_term_list_from_fraction, EXPECTED)
	#test("subtract_term_list_from_fraction 3", subtract_term_list_from_fraction, EXPECTED)

	#test("subtract_term_list_from_term(term_list, term) 1", subtract_term_list_from_term(term_list, term), EXPECTED)
	#test("subtract_term_list_from_term(term_list, term) 2", subtract_term_list_from_term(term_list, term), EXPECTED)
	#test("subtract_term_list_from_term(term_list, term) 3", subtract_term_list_from_term(term_list, term), EXPECTED)

	#test("subtract_term_list_from_term_list(tl_left, tl_right) 1", subtract_term_list_from_term_list(tl_left, tl_right), EXPECTED)
	#test("subtract_term_list_from_term_list(tl_left, tl_right) 2", subtract_term_list_from_term_list(tl_left, tl_right), EXPECTED)
	#test("subtract_term_list_from_term_list(tl_left, tl_right) 3", subtract_term_list_from_term_list(tl_left, tl_right), EXPECTED)

	#test("combine_redundant_terms_in_term_list term_list 1", combine_redundant_terms_in_term_list term_list, EXPECTED)
	#test("combine_redundant_terms_in_term_list term_list 2", combine_redundant_terms_in_term_list term_list, EXPECTED)
	#test("combine_redundant_terms_in_term_list term_list 3", combine_redundant_terms_in_term_list term_list, EXPECTED)


	# Testing Class: StackTraceElement
	#@StackTraceElement_obj = StackTraceElement.new()  # TODO: Add needed parameters.

	#test("StackTraceElement > initialize(line, col, fnc_name, *args) 1", @StackTraceElement_obj.initialize(line, col, fnc_name, *args), EXPECTED)
	#test("StackTraceElement > initialize(line, col, fnc_name, *args) 2", @StackTraceElement_obj.initialize(line, col, fnc_name, *args), EXPECTED)
	#test("StackTraceElement > initialize(line, col, fnc_name, *args) 3", @StackTraceElement_obj.initialize(line, col, fnc_name, *args), EXPECTED)

	#test("StackTraceElement > to_s 1", @StackTraceElement_obj.to_s, EXPECTED)
	#test("StackTraceElement > to_s 2", @StackTraceElement_obj.to_s, EXPECTED)
	#test("StackTraceElement > to_s 3", @StackTraceElement_obj.to_s, EXPECTED)



	#test("throw_error(msg, cur_ast_node, stack_trace)  1", throw_error(msg, cur_ast_node, stack_trace) , EXPECTED)
	#test("throw_error(msg, cur_ast_node, stack_trace)  2", throw_error(msg, cur_ast_node, stack_trace) , EXPECTED)
	#test("throw_error(msg, cur_ast_node, stack_trace)  3", throw_error(msg, cur_ast_node, stack_trace) , EXPECTED)


end

######################################################
#                  TESTING FUNCTION                  #
######################################################

def test( test_name, output, expected_output)

	if output != expected_output
		puts "TEST FAILED: #{test_name}"
		puts "\tResult:   #{output}"
		puts "\tExpected: #{expected_output}"
		if $config["exit_on_failure"]
			exit
		end
	else
		$tests_passed += 1
	end
end

######################################################
#                      RUN TESTS                     #
######################################################

run_tests
puts "NUMBER OF TESTS PASSED: #{$tests_passed}"
