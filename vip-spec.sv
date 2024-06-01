/*
MIT License

Copyright (c) 2024 William L. Moore

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

/*****************************************
Generate a ".f" argument file that points to this VIP's source files and directories. 

Usage:
    Run this file stand-alone in your simulator from the directory in which you will run your eventual simulation, e.g.:
    ```
        <simulator> vip-spec.sv
    ```
 
    This program generates the argument file `<name>.f` in the current working directory.
 
    Overwrites any existing file with the same name.
 
    Run your simulation with the generated argument file, e.g.:
    ```
        <simulator> <options> -f <name>.f <files>
    ```
*****************************************/

`timescale 1s/1ms

program \vip-spec ();

    /*
     * Specifier schema
     */
    typedef struct {
        string name, description, version, repository, author, license, bugs,
        homepage, path, incdirs[], files[];
    } spec_schema_t;
    
    /*
     * VIP specifier
     */
     static spec_schema_t spec = '{
        name: "bathtub",
        description: "BDD for SystemVerilog and UVM",
        version: "0.1.0",
        repository: "https://github.com/williaml33moore/bathtub.git",
        author: "Bill Moore <williaml33moore@gmail.com>",
        license: "MIT",
        bugs: "https://github.com/williaml33moore/bathtub/issues",
        homepage: "https://bathtubbdd.dev",
        path: `__FILE__,
        incdirs: '{
            "src"
        },
        files: '{
            "src/gherkin_pkg.sv",
            "src/bathtub_pkg.sv"
        },
        string: ""
    };

    typedef struct{string dir_name, base_name;} file_name_t;

    function file_name_t parse_file_name(string file_name, byte sep="/");
        string base_name;
        string dir_name;
        byte file_name_array[$];
        byte dir_name_array[$];
        byte base_name_array[$];
        int sep_indices[$];
        int sep_index;
        
        file_name_array.delete();
        foreach (file_name[i]) file_name_array.push_back(file_name[i]);

        // Handle the special cases first
        if (file_name_array.size() == 0) begin : filename_is_empty
            dir_name = ".";
            base_name = "";
        end
        else begin
            sep_indices = file_name_array.find_first_index(c) with (c != sep);
            if (sep_indices.size() == 0) begin : filename_is_all_slashes
                dir_name = "/";
                base_name = "/"; // This is what GNU `basename` does.
            end
            else begin
                sep_indices = file_name_array.find_first_index(c) with (c == sep);
                if (sep_indices.size() == 0) begin : filename_has_no_slashes
                    dir_name = "."; // This is what GNU `dirname` does.
                    base_name = file_name;
                end
                else begin : normal_case
                    while (file_name_array[$] == sep) void'(file_name_array.pop_back()); // Trim trailing slashes
                    sep_indices = file_name_array.find_last_index(c) with (c == sep);
                    sep_index = (sep_indices.size() > 0) ? sep_indices[0] : -1;
                    dir_name_array.delete();
                    dir_name_array = file_name_array[0:sep_index - 1];
                    while (dir_name_array[$] == sep) void'(dir_name_array.pop_back()); // Trim trailing slashes
                    base_name_array.delete();
                    base_name_array = file_name_array[sep_index + 1:$];
                    dir_name = "";
                    foreach (dir_name_array[i]) dir_name = {dir_name, dir_name_array[i]};
                    base_name = "";
                    foreach (base_name_array[i]) base_name = {base_name, base_name_array[i]};
                end
            end
        end
        parse_file_name = '{dir_name: dir_name, base_name: base_name};
    endfunction : parse_file_name

    function void test_parse_file_name();
        static string test_data[][] = '{
            '{"file_name", "expected_dir_name", "expected_base_name", "notes"},
            '{"/a/b/c", "/a/b", "c"},
            '{"/aa/bbb/cccc", "/aa/bbb", "cccc"},
            '{"/a/b/c/", "/a/b", "c"},
            '{"/a/b/c///", "/a/b", "c"},
            '{"a/b/c", "a/b", "c"},
            '{"a/b/c/", "a/b", "c"},
            '{"a/b/c///", "a/b", "c"},
            '{"c", ".", "c", "If there is no slash, dir_name should be '.'"},
            '{"cccc", ".", "cccc"},
            '{"./c", ".", "c"},
            '{"./cccc", ".", "cccc"},
            '{"a//b//c", "a//b", "c"},
            '{"//a//b//c//", "//a//b", "c"},
            '{"/", "/", "/", "Curiously this is what the GNU utils do"},
            '{"///", "/", "/", "Curiously this is what the GNU utils do"},
            '{"", ".", "", "Degenerate case; make sure it doesn't crash"}
        };
        file_name_t actual;
        string file_name, expected_dir_name, expected_base_name;

        foreach(test_data[i]) begin : test_data_loop
            if (i == 0) continue;
            file_name = test_data[i][0];
            expected_dir_name = test_data[i][1];
            expected_base_name = test_data[i][2];
            actual = parse_file_name(file_name);
            check_dir_name : assert (actual.dir_name == expected_dir_name)
                $info("file_name=%s, expected=%s, actual=%s", file_name, expected_dir_name, actual.dir_name);
            else
                $fatal(0, "file_name=%s, expected=%s, actual=%s", file_name, expected_dir_name, actual.dir_name);

            check_base_name : assert (actual.base_name == expected_base_name)
                $info("file_name=%s, expected=%s, actual=%s", file_name, expected_base_name, actual.base_name);
            else
                $fatal(0, "file_name=%s, expected=%s, actual=%s", file_name, expected_base_name, actual.base_name);
        end
    endfunction : test_parse_file_name
    
    function void main();
        static string file_name = "vip-spec.sv";
        static string base_name;
        string dir_name;
        string files_file_name;
        bit[31:0] files_fd;
        file_name_t parsed_file_name;

        parsed_file_name = parse_file_name(spec.path);
        dir_name = parsed_file_name.dir_name;
        base_name = parsed_file_name.base_name; 
        if (base_name != file_name)
            $fatal(0, "Spec file must be called '%s'. Actual spec file is called '%s'.", file_name, spec.path);
        files_file_name = {spec.name, ".f"};
        
        files_fd = $fopen(files_file_name, "w");
        if (files_fd == 0)
            $fatal(0, "Could not open file '%s' for writing.", files_file_name);

        $fdisplay(files_fd, {"// Automatically generated from VIP spec ", spec.path});
        $fdisplay(files_fd);
        foreach (spec.incdirs[i]) begin
            $fdisplay(files_fd, {"-incdir", " ", dir_name, "/", spec.incdirs[i]});
        end
        foreach (spec.files[i]) begin
            $fdisplay(files_fd, {dir_name, "/", spec.files[i]});
        end
        $fclose(files_fd);
    endfunction : main

`ifdef UNIT_TEST

    initial test_parse_file_name();

`else // UNIT_TEST

    initial main();

`endif // UNIT_TEST

endprogram : \vip-spec 