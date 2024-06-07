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

`ifndef __BATHTUB_UTILS_SVH
`define __BATHTUB_UTILS_SVH

`include "bathtub_pkg/bathtub_pkg.svh"

import uvm_pkg::*;

virtual class bathtub_utils;
// ===================================================================
	static function bit split_string;
// ===================================================================
/*			`FUNCTION_METADATA('{

				description:
				"Take a string containing tokens separated by white space, split the tokens, and return them in the supplied SystemVerilog queue.",

				details:
				"",

				categories:
				"utility",

				string: ""
			})
*/
		// Parameters:

		input string str;           // Incoming string of white space-separated tokens

		ref string tokens[$];   // Fills given queue with individual tokens

// ===================================================================
		typedef enum {START, TOKEN, WHITE_SPACE, FINISH} lex_state_t;
		lex_state_t state;
		byte c;
		string token;
		bit ok;

		ok = 1;
		tokens.delete();
		state = START;
		foreach (str[i]) begin
			c = str.getc(i);
			case (state)
				START: begin
					token = "";
					case (c)
						" ", "\t", "\n", CR : begin
							state = WHITE_SPACE;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				TOKEN: begin
					case (c)
						" ", "\t", "\n", CR : begin
							tokens.push_back(token);
							token = "";
							state = WHITE_SPACE;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				WHITE_SPACE: begin
					case (c)
						" ", "\t", "\n", CR : begin
							state = WHITE_SPACE;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				default: begin
					$fatal(1, "Unknown lexer state");
				end
			endcase
		end

		if (state == TOKEN) begin
			tokens.push_back(token);
			state = FINISH;
		end
		return ok;
	endfunction : split_string

// ===================================================================
	static function void split_lines;
// ===================================================================
/*			`FUNCTION_METADATA('{

				description:
				"Take a string containing lines separated by newlines, extract the lines, and return them in the supplied SystemVerilog queue.",

				details:
				"",

				categories:
				"utility",

				string: ""
			})
*/
		// Parameters:

		input string str;           // Incoming string of newline-separated lines

		ref string lines[$];   // Fills given queue with individual lines

// ===================================================================
		byte c;
		string line;

		lines.delete();
		line = "";
		foreach (str[i]) begin
			c = str.getc(i);
			case (c)
				"\n", CR : begin
					lines.push_back(line);
					line = "";
				end
				default : begin
					line = {line, c};
				end
			endcase
		end

		if (line.len() > 0) begin
			lines.push_back(line);
		end
	endfunction : split_lines
	
	
	static function string get_conversion_spec(string str);
		typedef enum {LOOKING_FOR_START, START, WIDTH, CODE} lex_state_t;
		lex_state_t state;
		byte c;
		string spec;

		state = LOOKING_FOR_START;
		spec = "";
		
		foreach (str[i]) begin
			c = str[i];
			case (state)
				LOOKING_FOR_START : begin : state_$looking_for_start
					case (c)
						"%" : begin
							state = START;
							spec = {spec, string'(c)};
						end
					endcase
				end
				
				START : begin : state_$start
					case (c)
						"%" : begin : case_$escaped_percent_sign
							state = LOOKING_FOR_START;
							spec = "";
						end
						
						"0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : begin : case_$optional_width
							state = WIDTH;
							spec = {spec, string'(c)};
						end
						
						"b", "o", "d", "h", "x", "f", "e", "g", "c", "s",
						"B", "O", "D", "H", "X", "F", "E", "G", "C", "S": begin : case_$code
							state = CODE;
							spec = {spec, string'(c)};
						end
						
						default : begin : case_$unsupported_code
							$fatal(1, $sformatf("Unsupported conversion specification character: %s", c));
						end
					endcase
				end
				
				WIDTH : begin : state_$width
					case (c)
						"0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : begin : case_$optional_width
							state = WIDTH;
							spec = {spec, string'(c)};
						end
						
						"b", "o", "d", "h", "x", "f", "e", "g", "c", "s",
						"B", "O", "D", "H", "X", "F", "E", "G", "C", "S": begin : case_$code
							state = CODE;
							spec = {spec, string'(c)};
						end
						
						default : begin : case_$unsupported_code
							$fatal(1, $sformatf("Unsupported conversion specification character: %s", c));
						end
					endcase
				end
				
				CODE : begin : state_$CODE
					break;
				end

				default: begin
					$fatal(1, "Unknown lexer state");
				end
			endcase
		end

		return spec;
	endfunction : get_conversion_spec
	
	
	static function string get_conversion_code(string token);
		typedef enum {LOOKING_FOR_START, START, WIDTH, CODE} lex_state_t;
		lex_state_t state;
		byte c;
		string code;
		string spec;

		spec = get_conversion_spec(token);
		code = (spec == "") ? "" : string'(spec[spec.len() - 1]);
		
		return code;
	endfunction : get_conversion_code
	
	
	static function bit is_regex(string expression);
		bit result;
		byte first_char;
		byte last_char;
		
		expression = trim_white_space(expression);
		first_char = expression[0];
		last_char = expression[expression.len() - 1];
		result = (first_char == "/"  && last_char == "/") ||
			(first_char == "^" && last_char =="$");
		
		return result;
		
	endfunction : is_regex
	
	
	static function string bathtub_to_regexp(string bathtub_exp);
		string regexp_from_code[string] = '{
			"b" : "([0-1XxZz?_]+)",
			"o" : "([0-7XxZz?_]+)",
			"d" : "(([-+]?[0-9_]+)|[xXzZ?])",
			"h" : "([0-9a-fA-FxXzZ?_]+)",
			"x" : "([0-9a-fA-FxXzZ?_]+)",
			"f" : "([+-]?[0-9]+.?[0-9]*[eE]?[+-]?[0-9]*)",
			"e" : "([+-]?[0-9]+.?[0-9]*[eE]?[+-]?[0-9]*)",
			"g" : "([+-]?[0-9]+.?[0-9]*[eE]?[+-]?[0-9]*)",
			"s" : "(\\S*)",
			"c" : "(.)"
		};
		string result = bathtub_exp;

		forever begin
			string spec = get_conversion_spec(result);
			string code;
			string subst_regexp;
			int result_length = result.len();
			int spec_length = spec.len();
			string before_subst = result;
			
//				$info(result);
			
			if (spec == "") break;
			
			code = get_conversion_code(spec);
			code = code.tolower();
			subst_regexp = regexp_from_code[code];
			
			for (int i = 0; i < result_length; i++) begin
				if (result.substr(i, i + spec_length - 1) == spec) begin
					result = {result.substr(0, i - 1), subst_regexp, result.substr(i + spec.len(), result_length - 1)};
					break;
				end
			end
			
			// Prevents an infinite loop.
			assert_substitution_done : assert (before_subst != result) else
				$fatal(1, "Failed to substitute conversion spec '%s' in expression '%s'", spec, result);
		end

		return {"/^", result, "$/"};
	endfunction : bathtub_to_regexp
	
	
	static function int re_match(string re, string str);
		return uvm_re_match(re, str);
	endfunction : re_match


	static function bit string_starts_with(string text_to_search, string search_text);
		return (search_text == text_to_search.substr(0, search_text.len() - 1));
	endfunction : string_starts_with


	static function string trim_white_space(string line_buf);
		byte c;
		int index_of_first_non_white_space;
		int index_of_last_non_white_space;

		index_of_first_non_white_space = line_buf.len(); // Beyond the end
		for (int i = 0; i < line_buf.len(); i++) begin
			c = line_buf[i];

			if (!(c inside {" ", "\t", "\n", CR})) begin
				index_of_first_non_white_space = i;
				break;
			end
		end

		index_of_last_non_white_space = -1; // Beyond the end
		for (int i = line_buf.len() - 1; i >= 0; i--) begin
			c = line_buf[i];

			if (!(c inside {" ", "\t", "\n", CR})) begin
				index_of_last_non_white_space = i;
				break;
			end
		end

		line_buf = line_buf.substr(index_of_first_non_white_space, index_of_last_non_white_space);
		return line_buf;
	endfunction : trim_white_space

endclass : bathtub_utils

`endif // __BATHTUB_UTILS_SVH
