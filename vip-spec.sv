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
    
    function void main();
        static string file_name = "vip-spec.sv";
        static string base_name;
        string dir_name;
        string files_file_name;
        bit[31:0] files_fd;

        base_name = spec.path.substr(spec.path.len() - file_name.len(), spec.path.len() - 1);
        if (base_name != file_name)
            $fatal(0, "Spec file must be called '%s'. Actual spec file is called '%s'.", file_name, spec.path);
        dir_name = spec.path.substr(0, spec.path.len() - base_name.len() - 1);
        if (dir_name[dir_name.len() - 1] == "/")
            dir_name = dir_name.substr(0, dir_name.len() - 2);
        if (dir_name.len() == 0)
            dir_name = ".";
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

    initial main();

endprogram : \vip-spec 