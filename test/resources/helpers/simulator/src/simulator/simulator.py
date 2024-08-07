# MIT License
#
# Copyright (c) 2024 William L. Moore
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import subprocess

class Simulator:
    """Asbtraction of SystemVerilog Simulators"""
    def __init__(self):
        self.reset()

    def reset(self):
        self.args = []
        self.returncode = -1
        self.uvm_flag = False
        self.uvm_home = None
        return self
    
    def append_arg(self, arg):
        """Append a single argument to simulator command-line arguments."""
        self.args.append(arg)
        return self
    
    def extend_args(self, args):
        """Extend simulator command-line arguments with a list of new arguments."""
        self.args.extend(args)
        return self
    
    def uvm(self, uvm_home=None, is_builtin=True):
        """Enable UVM with the given UVM installation."""
        self.uvm_flag = True
        self.append_arg('-uvm')
        if uvm_home is not None:
            self.append_arg('-uvmhome ' + uvm_home)
        return self

    def run(self, cwd='.'):
        """Run the simulator and store the process' return code (0=success)."""
        assert 'binary' in dir(self), "Simulator '" + self.name() + "' has no attribute 'binary'; use a concrete Simulator instead."
        run_cmd = " ".join([self.binary] + self.args)
        self.returncode = subprocess.run(run_cmd, shell=True, cwd=cwd).returncode
        return self
    
    def passed(self):
        """Return True if the simulator's return code is 0 (success), False otherwise."""
        return self.returncode == 0
    
    def name(self):
        """Return the simulator class' name."""
        return self.__class__.__name__
