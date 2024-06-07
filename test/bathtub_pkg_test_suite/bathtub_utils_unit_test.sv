/*
MIT License

Copyright (c) 2023 Everactive

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

`include "svunit_defines.svh"
import bathtub_pkg::*;

module bathtub_utils_unit_test;
	import svunit_pkg::svunit_testcase;

	string name = "bathtub_utils_ut";
	svunit_testcase svunit_ut;


	//===================================
	// This is the UUT that we're
	// running the Unit Tests on
	//===================================

	// Miscellaneous variables
	bit ok;


	//===================================
	// Build
	//===================================
	function void build();
		svunit_ut = new(name);
	endfunction


	//===================================
	// Setup for running the Unit Tests
	//===================================
	task setup();
		svunit_ut.setup();
	/* Place Setup Code Here */

	endtask


	//===================================
	// Here we deconstruct anything we
	// need after running the Unit Tests
	//===================================
	task teardown();
		svunit_ut.teardown();
		/* Place Teardown Code Here */

		#1;
	endtask


	//===================================
	// All tests are defined between the
	// SVUNIT_TESTS_BEGIN/END macros
	//
	// Each individual test must be
	// defined between `SVTEST(_NAME_)
	// `SVTEST_END
	//
	// i.e.
	//   `SVTEST(mytest)
	//     <test code>
	//   `SVTEST_END
	//===================================
	`SVUNIT_TESTS_BEGIN


	`SVTEST(split_string_should_split_strings_on_white_space)
	// ======================================================
	string str;
	string tokens[$];

	str = "alpha bravo charlie";
	ok = bathtub_pkg::bathtub_utils::split_string(str, tokens);

	`FAIL_UNLESS_LOG(ok, "should return OK")

	`FAIL_UNLESS_STR_EQUAL(tokens[0], "alpha")
	`FAIL_UNLESS_STR_EQUAL(tokens[1], "bravo")
	`FAIL_UNLESS_STR_EQUAL(tokens[2], "charlie")
	`SVTEST_END


	`SVTEST(split_lines_should_split_strings_on_newlines)
	// ==================================================
	struct {
		string str;
		string expected_lines[];
	} examples[];
	string str;
	string actual_lines[$];

	examples = '{
		'{
			str : "alpha\nbravo\ncharlie\ndelta\necho\n",
			expected_lines : {"alpha", "bravo", "charlie", "delta", "echo"}
		},
		'{
			str : "alpha\nbravo\ncharlie\ndelta\necho",
			expected_lines : {"alpha", "bravo", "charlie", "delta", "echo"}
		},
		'{
			str : "\nalpha\n\ncharlie\ndelta\n",
			expected_lines : {"", "alpha", "", "charlie", "delta"}
		},
		'{
			str : "\nalpha\n\ncharlie\n\n",
			expected_lines : {"", "alpha", "", "charlie", ""}
		},
		'{
			str : "\n",
			expected_lines : {""}
		},
		'{
			str : "",
			expected_lines : {}
		}
	};

	foreach (examples[i]) begin
		str = examples[i].str;
		bathtub_pkg::bathtub_utils::split_lines(str, actual_lines);

		`FAIL_UNLESS_EQUAL(actual_lines.size(), examples[i].expected_lines.size())

		foreach (examples[i].expected_lines[j]) begin
			`FAIL_UNLESS_STR_EQUAL(actual_lines[j], examples[i].expected_lines[j])
		end
	end
	`SVTEST_END


	`SVTEST(Get_conversion_spec_extracts_the_conversion_spec_from_a_string)
	// ======================================================================
	struct {
		string str;
		string expected_conversion_spec;
	} examples[$];
	string actual_conversion_spec;

	(* Examples *)
	examples = '{
		'{
			str : "%d",
			expected_conversion_spec : "%d"
		},
		'{
			str : "%0d",
			expected_conversion_spec : "%0d"
		},
		'{
			str : "%10s",
			expected_conversion_spec : "%10s"
		},
		'{
			str : "abc%defg",
			expected_conversion_spec : "%d"
		},
		'{
			str : "abcdefg",
			expected_conversion_spec : ""
		},
		'{
			str : "%bcdefg",
			expected_conversion_spec : "%b"
		},
		'{
			str : "100%%_%s",
			expected_conversion_spec : "%s"
		},
		'{
			str : "xyz%88h123",
			expected_conversion_spec : "%88h"
		},
		'{
			str : "qwerty%10g",
			expected_conversion_spec : "%10g"
		},
		'{
			str : "",
			expected_conversion_spec : ""
		},
		'{
			str : "dog %000f cat",
			expected_conversion_spec : "%000f"
		}
	};

	foreach (examples[i]) begin
		(* When = "I find a conversion specification in a string" *)
		actual_conversion_spec = bathtub_pkg::bathtub_utils::get_conversion_spec(examples[i].str);

		(* Then = "it should match the expected specification" *)
		`FAIL_UNLESS_STR_EQUAL(actual_conversion_spec, examples[i].expected_conversion_spec)
	end

	`SVTEST_END


	`SVTEST(Get_conversion_code_extracts_the_conversion_code_from_a_token)
	// =====================================================================
	struct {
		string token;
		string expected_conversion_code;
	} examples[$];
	string actual_conversion_code;

	(* Examples *)
	examples = '{
		'{
			token : "%d",
			expected_conversion_code : "d"
		},
		'{
			token : "%0d",
			expected_conversion_code : "d"
		},
		'{
			token : "%10s",
			expected_conversion_code : "s"
		},
		'{
			token : "abc%defg",
			expected_conversion_code : "d"
		},
		'{
			token : "abcdefg",
			expected_conversion_code : ""
		},
		'{
			token : "%bcdefg",
			expected_conversion_code : "b"
		},
		'{
			token : "100%%_%s",
			expected_conversion_code : "s"
		}
	};

	foreach (examples[i]) begin
		(* When = "I get a conversion code from a token" *)
		actual_conversion_code = bathtub_pkg::bathtub_utils::get_conversion_code(examples[i].token);

		(* Then = "it should match the expected code" *)
		`FAIL_UNLESS_STR_EQUAL(actual_conversion_code, examples[i].expected_conversion_code)
	end

	`SVTEST_END


	`SVTEST(Is_regex_tests_whether_a_string_is_a_regular_expression)
	// ===============================================================
	struct {
		string str;
		bit expected;
	} examples[$];
	bit actual;

	(* Examples *)
	examples = '{
		'{str : "/this is a regular expression/", expected : 1},
		'{str : "^this is a regular expression$", expected : 1},
		'{str : "this is not a regular expression", expected : 0},
		'{str : "/this is not a regular expression", expected : 0},
		'{str : "this is not a regular expression/", expected : 0},
		'{str : "^this is not a regular expression", expected : 0},
		'{str : "this is not a regular expression$", expected : 0},
		'{str : "^this is not a regular expression/", expected : 0},
		'{str : "/this is not a regular expression$", expected : 0},
		'{str : "//", expected : 1},
		'{str : "^$", expected : 1},
		'{str : "%&", expected : 0},
		'{str : "", expected : 0}
	};

	foreach (examples[i]) begin

		(* When = "I test strings which may or may not be regular expressions" *)
		actual = bathtub_utils::is_regex(examples[i].str);

		(* Then = "I get the expected result" *)
		`FAIL_UNLESS_EQUAL(actual, examples[i].expected)

	end
	`SVTEST_END


	`SVTEST(Bathtub_to_regexp_converts_a_bathtub_expression_to_a_regular_expression)
	// ===============================================================================
	localparam
		binary_re = "([0-1XxZz?_]+)",
		octal_re = "([0-7XxZz?_]+)",
		hex_re = "([0-9a-fA-FxXzZ?_]+)",
		int_re = "(([-+]?[0-9_]+)|[xXzZ?])",
		real_re = "([+-]?[0-9]+.?[0-9]*[eE]?[+-]?[0-9]*)",
		string_re = "(\\S*)",
		char_re = "(.)";
	
	struct {
		string bathtub_exp;
		string expected;
	} examples[$];
	string actual;

	(* Examples *)
	examples = '{
		'{bathtub_exp : "no special characters", expected : "/^no special characters$/"},
		'{bathtub_exp : "%b", expected : $sformatf("/^%s$/", binary_re)},
		'{bathtub_exp : "%B", expected : $sformatf("/^%s$/", binary_re)},
		'{bathtub_exp : "%o", expected : $sformatf("/^%s$/", octal_re)},
		'{bathtub_exp : "%O", expected : $sformatf("/^%s$/", octal_re)},
		'{bathtub_exp : "%d", expected : $sformatf("/^%s$/", int_re)},
		'{bathtub_exp : "%D", expected : $sformatf("/^%s$/", int_re)},
		'{bathtub_exp : "%h", expected : $sformatf("/^%s$/", hex_re)},
		'{bathtub_exp : "%H", expected : $sformatf("/^%s$/", hex_re)},
		'{bathtub_exp : "%x", expected : $sformatf("/^%s$/", hex_re)},
		'{bathtub_exp : "%X", expected : $sformatf("/^%s$/", hex_re)},
		'{bathtub_exp : "%f", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%F", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%e", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%E", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%g", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%G", expected : $sformatf("/^%s$/", real_re)},
		'{bathtub_exp : "%s", expected : $sformatf("/^%s$/", string_re)},
		'{bathtub_exp : "%S", expected : $sformatf("/^%s$/", string_re)},
		'{bathtub_exp : "%c", expected : $sformatf("/^%s$/", char_re)},
		'{bathtub_exp : "%C", expected : $sformatf("/^%s$/", char_re)},
		'{bathtub_exp : "embedded %d code", expected : $sformatf("/^embedded %s code$/", int_re)},
		'{bathtub_exp : "%f leading code", expected : "/^([+-]?[0-9]+.?[0-9]*[eE]?[+-]?[0-9]*) leading code$/"},
		'{bathtub_exp : "trailing code %s", expected : "/^trailing code (\\S*)$/"},
		'{bathtub_exp : "multiple codes: int %d, real %f, string %s",
			expected : $sformatf("/^multiple codes: int %s, real %s, string %s$/", int_re, real_re, string_re)},
		'{bathtub_exp : "adjacent codes: %d%f%s",
			expected : $sformatf("/^adjacent codes: %s%s%s$/", int_re, real_re, string_re)},


		'{bathtub_exp : "", expected : "/^$/"}
	};

	foreach (examples[i]) begin

		(* When = "I convert bathtub expression <bathtub_exp>" *)
		actual = bathtub_utils::bathtub_to_regexp(examples[i].bathtub_exp);

		(* Then = "I get the expected result <expected>" *)
		`FAIL_UNLESS_STR_EQUAL(actual, examples[i].expected)

	end

	`SVTEST_END


	`SVTEST(Integer_regular_expression_matches_$sscanf_result)
	// =========================================================
	struct {
		string format;
		string str;
	} examples[$];

	(* Examples *)
	examples = '{
		'{format : "%d", str : "not a match"},
		'{format : "%d", str : "42"},
		'{format : "%d", str : "+1"},
		'{format : "%d", str : "-035"},
		'{format : "%d", str : "246_789"},
		'{format : "%d", str : "+_0_1_0_"},
		'{format : "%d", str : "z"},
		'{format : "%d", str : "+Z"},
		'{format : "%d", str : "-x"},
		'{format : "%d", str : "?"},
		
		'{format : "The answer is %0d", str : "The answer is 777"}
	};

	foreach (examples[i]) begin
		struct {
			string regexp;
			bit scan_ok;
			int arg;
			bit re_match_ok;
		} result;

		(* When = "I generate a regular expression from format '<format>'" *)
		result.regexp = bathtub_utils::bathtub_to_regexp(examples[i].format);

		(* Then = "scanning a string with `$sscanf()` and matching the same string with `uvm_re_match()` should give the same result" *)

		result.scan_ok = $sscanf(examples[i].str, examples[i].format, result.arg) == 1; // One match

		// `uvm_re_match()` returns 0 if `str` matches `regexp`, meaning there are no "errors."
		result.re_match_ok = bathtub_utils::re_match(result.regexp, examples[i].str) == 0;

		`ifdef DEBUG
		$info($sformatf("examples[%0d]: %p", i, examples[i]));
		$info($sformatf("result: %p", result));
		`endif

		`FAIL_UNLESS_EQUAL(result.scan_ok, result.re_match_ok)

	end

	`SVTEST_END


	`SVTEST(Real_number_regular_expression_matches_$sscanf_result)
	// =============================================================
	struct {
		string format;
		string str;
	} examples[$];

	(* Examples *)
	examples = '{
		'{format : "%f", str : "42"},
		'{format : "%f", str : "42.000"},
		'{format : "%f", str : "13.5e3"},
		'{format : "%f", str : "-69.7e6"},
		'{format : "%f", str : "1e-9"},
		'{format : "%f", str : "-9e0"},
		'{format : "%f", str : "not a match"}
	};

	foreach (examples[i]) begin
		string regexp;
		bit scan_ok;
		real arg;
		bit re_match_ok;

		(* When = "I generate a regular expression from format '<format>'" *)
		regexp = bathtub_utils::bathtub_to_regexp(examples[i].format);

		(* Then = "scanning a string with `$sscanf()` and matching the same string with `uvm_re_match()` should give the same result" *)

		scan_ok = $sscanf(examples[i].str, examples[i].format, arg) == 1; // One match

		// `uvm_re_match()` returns 0 if `str` matches `regexp`, meaning there are no "errors."
		re_match_ok = bathtub_utils::re_match(regexp, examples[i].str) == 0;

		`FAIL_UNLESS_EQUAL(scan_ok, re_match_ok)

	end

	`SVTEST_END


	`SVTEST(String_regular_expression_matches_$sscanf_result )
	// ========================================================
	struct {
		string format;
		string str;
	} examples[$];

	(* Examples *)
	examples = '{
		'{format : "alpha %s charlie", str : "alpha bravo charlie"},
		'{format : "alpha bravo %s", str : "alpha bravo charlie"},
		'{format : "alpha bravo %s", str : "alpha bravo"}
	};

	foreach (examples[i]) begin

		struct {
			string regexp;
			bit scan_ok;
			bit re_match_ok;
			string arg;
		} result;

		(* When = "I generate a regular expression from format '<format>'" *)
		result.regexp = bathtub_utils::bathtub_to_regexp(examples[i].format);

		(* Then = "scanning a string with `$sscanf()` and matching the same string with `uvm_re_match()` should give the same result" *)

		result.scan_ok = $sscanf(examples[i].str, examples[i].format, result.arg) == 1; // One match

		// `uvm_re_match()` returns 0 if `str` matches `regexp`, meaning there are no "errors."
		result.re_match_ok = bathtub_utils::re_match(result.regexp, examples[i].str) == 0;

`ifdef DEBUG
		$info($sformatf("%p", examples[i]));
		$info($sformatf("%p", result));
`endif

		`FAIL_UNLESS_EQUAL(result.scan_ok, result.re_match_ok)

	end

	`SVTEST_END


	// ---
	`SVUNIT_TESTS_END

endmodule

