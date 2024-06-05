	task gherkin_parser::parse_gherkin_document(ref gherkin_pkg::gherkin_document gherkin_document);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::gherkin_document_value gherkin_document_value;
		int feature_count = 0;

		// Prime the mailbox so it contains the first non-empty line

		forever begin : find_first_non_empty_line
			line_mbox.peek(line_obj);

			if (line_obj.eof) break;

			else if (bathtub_utils::trim_white_space(line_obj.text) == "") begin
				// Ignore empty lines
				get_next_line(line_obj);
			end

			else begin
				// Mailbox is ready
				break;
			end
		end

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_gherkin_document enter", UVM_HIGH)
		`uvm_message_add_string(line_obj.file_name)
		`uvm_message_add_int(line_obj.line_number, UVM_DEC)
		`uvm_message_add_int(line_obj.eof, UVM_BIN)
		if (!line_obj.eof) begin
			`uvm_message_add_string(line_obj.text)
		end
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

		while (status == OK) begin : document_elements
			line_mbox.peek(line_obj);

			if (line_obj.eof) break;

			analyze_line(line_obj.text, line_analysis_result);

			case (line_analysis_result.token_before_colon)

				"Feature" : begin : construct_feature
					gherkin_pkg::feature feature;

					parse_feature(feature);
					`pop_from_parser_stack(feature)

					if (status == OK) begin
						if (feature_count == 0) begin
							gherkin_document_value.feature = feature;
							feature_count++;
						end
						else begin
							status = ERROR;
							`uvm_error(`get_scope_name(), "A Gherkin document can have only one feature")
						end
					end
				end

				default : begin

					case (line_analysis_result.secondary_keyword)

						"#" : begin : construct_comment
							gherkin_pkg::comment comment;

							parse_comment(comment);
							`pop_from_parser_stack(comment)
							if (status == OK) begin
								gherkin_document_value.comments.push_back(comment);
							end
						end

						default : begin
							status = ERROR;
							`uvm_error(`get_scope_name(), {"Syntax error. Expecting \"Feature:\" or \"#\".",
								"\n", line_obj.text})
							get_next_line(line_obj);
							break;
						end
					endcase
				end
			endcase
		end

		gherkin_document = new("gherkin_document", gherkin_document_value);
		`push_onto_parser_stack(gherkin_document)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_gherkin_document exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(gherkin_document)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_gherkin_document
