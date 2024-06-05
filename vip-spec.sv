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
Generate a ".f" argument file and shell setup scripts that point to this VIP's source files and directories. 

Usage:
    Run this file stand-alone in your simulator from the directory in which you will run your eventual simulation, e.g.:
    ```
        <simulator> /absolute/path/to/vip-spec.sv
    ```
 
    This program generates the argument file `<name>_vip.f`, a csh script `<name>_vip.csh`, and a bash script `<name>_vip.sh` in the current working directory.
 
    Overwrites any existing files with the same names.

    The generated files generally contain the `vip-spec.sv` path you gave to the simulator.

    If you give the simulator a relative path to `vip-spec.sv`, e.g., `<simulator> ../../vip-spec.sv`, then the generated files will contain the relative path `../../`.

    If you give the simulator an absolute path to `vip-spec.sv`, e.g. `<simulator> /absolute/path/to/vip-spec.sv`, then the generated files will contain the absolute path `/absolute/path/to/`.

    Set up your simulation shell with the generated shell scripts, e.g.:
    ```
    source <name>_vip.csh # csh
    or
    source <name>_vip.sh # bash
    ```
 
    Run your simulation with the generated argument file, e.g.:
    ```
        <simulator> <options> -f <name>.f <files>
    ```
*****************************************/

`timescale 1s/1ms

package bathtub_$vip_spec;

    /*
     * Specifier schema
     */
    typedef struct {
        string name, description, version, repository, author, license, bugs,
        homepage, path, incdirs[], files[];
    } spec_schema;
    
    /*
     * VIP specifier
     */
     const var static spec_schema spec = '{
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
            "src/gherkin_pkg",
            "src/bathtub_pkg"
        },
        files: '{
            "src/gherkin_pkg/gherkin_pkg.sv",
            "src/bathtub_pkg/bathtub_pkg.sv"
        },
        string: ""
    };

endpackage : bathtub_$vip_spec


program bathtub_$vip_init();
    typedef struct{string dir_name, base_name;} file_name_t;

    function file_name_t parse_file_name(string file_name, byte sep="/");
        string base_name;
        string dir_name;
        byte unsigned file_name_array[$];
        byte unsigned dir_name_array[$];
        byte unsigned base_name_array[$];
        int sep_indices[$];
        int sep_index;
        
        file_name_array.delete();
        foreach (file_name[i]) file_name_array.push_back(file_name[i]);
        // Trim whitespace and non-printable characters from ends
        while ((file_name_array.size() > 0) && !(file_name_array[$] inside {[33:126]})) void'(file_name_array.pop_back());
        while ((file_name_array.size() > 0) && !(file_name_array[0] inside {[33:126]})) void'(file_name_array.pop_front());

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
                    base_name = "";
                    foreach (file_name_array[i]) base_name = {base_name, file_name_array[i]};
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
            '{" /a/b/c", "/a/b", "c"},
            '{"/a/b/c  ", "/a/b", "c"},
            '{"   /a/b/c   ", "/a/b", "c"},
            '{"/aa/bbb/cccc", "/aa/bbb", "cccc"},
            '{"/a/b/c/", "/a/b", "c"},
            '{"/a/b/c///", "/a/b", "c"},
            '{"a/b/c", "a/b", "c"},
            '{"a/b/c/", "a/b", "c"},
            '{"a/b/c///", "a/b", "c"},
            '{"c", ".", "c", "If there is no slash, dir_name should be '.'"},
            '{"cccc", ".", "cccc"},
            '{"  cccc", ".", "cccc"},
            '{"cccc   ", ".", "cccc"},
            '{"     cccc   ", ".", "cccc"},
            '{"./c", ".", "c"},
            '{"./cccc", ".", "cccc"},
            '{"a//b//c", "a//b", "c"},
            '{"//a//b//c//", "//a//b", "c"},
            '{"/", "/", "/", "Curiously this is what the GNU utils do"},
            '{"///", "/", "/", "Curiously this is what the GNU utils do"},
            '{"", ".", "", "Degenerate case; make sure it doesn't crash"},
            '{"       ", ".", ""}
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

    function void gen_args_file(bathtub_$vip_spec::spec_schema spec, string dir_name, string base_name);
        string file_name;
        bit[31:0] fd;
        string buffer[$];

        file_name = {spec.name, "_vip.f"};
        
        fd = $fopen(file_name, "w");
        if (fd == 0)
            $fatal(0, "Could not open file '%s' for writing.", file_name);

        buffer.delete();
        buffer.push_back({"// Automatically generated from VIP spec ", spec.path});
        buffer.push_back("");
        foreach (spec.incdirs[i]) begin
            buffer.push_back({"-incdir", " ", dir_name, "/", spec.incdirs[i]});
        end
        foreach (spec.files[i]) begin
            buffer.push_back({dir_name, "/", spec.files[i]});
        end

        foreach(buffer[i]) begin
            $display(buffer[i]);
            $fdisplay(fd, buffer[i]);
        end

        $fclose(fd);
    endfunction : gen_args_file

    function string gen_env_var(bathtub_$vip_spec::spec_schema spec);
        gen_env_var = {spec.name.toupper(), "_VIP_DIR"};
    endfunction : gen_env_var

    function void gen_setup_csh(bathtub_$vip_spec::spec_schema spec, string dir_name, string base_name);
        string file_name;
        string env_var;
        bit[31:0] fd;
        string buffer[$];

        file_name = {spec.name, "_vip.csh"};
        env_var = gen_env_var(spec);
        
        fd = $fopen(file_name, "w");
        if (fd == 0)
            $fatal(0, "Could not open file '%s' for writing.", file_name);

        buffer.delete();
        buffer.push_back({"# Automatically generated from VIP spec ", spec.path});
        buffer.push_back("");
        buffer.push_back({"setenv", " ", env_var, " ", dir_name});

        foreach(buffer[i]) begin
            $display(buffer[i]);
            $fdisplay(fd, buffer[i]);
        end

        $fclose(fd);
    endfunction : gen_setup_csh

    function void gen_setup_sh(bathtub_$vip_spec::spec_schema spec, string dir_name, string base_name);
        string file_name;
        string env_var;
        bit[31:0] fd;
        string buffer[$];

        file_name = {spec.name, "_vip.sh"};
        env_var = gen_env_var(spec);
        
        fd = $fopen(file_name, "w");
        if (fd == 0)
            $fatal(0, "Could not open file '%s' for writing.", file_name);

        buffer.delete();
        buffer.push_back({"# Automatically generated from VIP spec ", spec.path});
        buffer.push_back("");
        buffer.push_back({"export", " ", env_var, "=", dir_name});

        foreach(buffer[i]) begin
            $display(buffer[i]);
            $fdisplay(fd, buffer[i]);
        end

        $fclose(fd);
    endfunction : gen_setup_sh
    
    function void main(bathtub_$vip_spec::spec_schema spec);
        file_name_t parsed_file_name;
        string dir_name;
        string base_name;
        const static string file_name = "vip-spec.sv";

        parsed_file_name = parse_file_name(spec.path);
        dir_name = parsed_file_name.dir_name;
        base_name = parsed_file_name.base_name; 
        if (base_name != file_name)
            $fatal(0, "Spec file must be called '%s'. Actual spec file is called '%s'.", file_name, spec.path);
        gen_args_file(spec, dir_name, base_name);
        gen_setup_csh(spec, dir_name, base_name);
        gen_setup_sh(spec, dir_name, base_name);
        $fflush();
    endfunction : main

`ifdef UNIT_TEST

    initial test_parse_file_name();

`else // UNIT_TEST

    initial main(bathtub_$vip_spec::spec);

`endif // UNIT_TEST

endprogram : bathtub_$vip_init

