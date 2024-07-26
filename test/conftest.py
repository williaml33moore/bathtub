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
import pytest
import yaml
import os

class Simulator:
    """Abtraction of SystemVerilog Simulators"""
    def __init__(self):
        self.args = []
        self.returncode = -1
        self.uvm_flag = False
        self.uvm_home = None
    
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

class Xcelium(Simulator):
    """Abstraction of Xcelium simulator"""
    def __init__(self):
        super().__init__()
        self.binary = 'xrun'
        self.log = 'xrun.log'
    
    def uvm(self, uvm_home=None, is_builtin=True):
        super().uvm(uvm_home)
        # Xcelium requires additional arg when not using built-in UVM installation.
        if not is_builtin:
            self.append_arg('-uvmnocdnsextra')
        return self

class Questa(Simulator):
    """Abstraction of Questa simulator"""
    def __init__(self):
        super().__init__()
        self.binary = 'qrun'
        self.log = 'qrun.log'

    def run(self, cwd='.'):
        """Run the simulator then do additional result checks."""
        super().run(cwd)
        if self.returncode != 0:
            # Simulator returned nonzero, indicating a problem
            return self
        
        # Simulator returned, so do additional log checks
        run_cmd = "perl $BATHTUB_VIP_DIR/test/scripts/qrun_result.pl"
        self.returncode = subprocess.run(run_cmd, shell=True, cwd=cwd).returncode
        return self

class SVUnit:
    """Abstraction of runSVUnit script"""
    def __init__(self):
        self.simulator = None
        self.uvm_flag = False
        self.output_dir = None
        self.args = []
        self.script = 'runSVUnit'
        self.returncode = -1
        self.compile_arg = None
    
    def append_arg(self, arg):
        """Append a single argument to script command-line arguments."""
        self.args.append(arg)
        return self
    
    def extend_args(self, args):
        """Extend script command-line arguments with a list of new arguments."""
        self.args.extend(args)
        return self

    def sim(self, simulator):
        """Set the script's --sim option based on given simulator class."""
        sim_arg_values = {
            'Xcelium' : 'xcelium',
            'Questa' : 'qrun'
        }
        self.simulator = simulator
        self.args.append('--sim ' + sim_arg_values[self.simulator.name()])
        return self
    
    def c_arg(self, compile_arg):
        """Set the script's --c_arg option to given compiler options."""
        self.compile_arg = compile_arg
        self.args.append('--c_arg ' + self.compile_arg)
        return self
    
    def uvm(self, uvm_flag=True, uvm_home=None, is_builtin=True):
        """Set the script's --uvm option"""
        self.uvm_flag = uvm_flag
        if self.uvm_flag:
            self.args.append('--uvm')
        if uvm_home is not None:
            self.args.append("--c_arg '-uvmhome " + uvm_home + "'")
        if self.simulator.name() == 'Xcelium' and not is_builtin:
            # Xcelium requires additional compile arg when not using built-in UVM installation.
            self.args.append("--c_arg '-uvmnocdnsextra'")
        return self
    
    def out(self, output_dir):
        """Set the script's --out option to given directory."""
        self.output_dir = output_dir
        self.args.append('--out ' + str(output_dir))
        return self
    
    def check_testrunner_result(self, cwd='.'):
        """Grep run.log for a positive "PASSED" message and return True if successful."""
        if self.simulator.name() == 'Questa':
            checker_cmd = "grep '^# INFO.*testrunner.*PASSED' " + str(self.output_dir) + "/run.log"
        else:
            checker_cmd = "grep '^INFO.*testrunner.*PASSED' " + str(self.output_dir) + "/run.log"
        self.returncode = subprocess.run(checker_cmd, shell=True, cwd=cwd).returncode
    
    def run(self, cwd='.'):
        """Run the script and check results and store the return code (0=success)."""
        svunit_cmd = " ".join([self.script] + self.args)
        self.returncode = subprocess.run(svunit_cmd, shell=True, cwd=cwd).returncode
        if self.returncode == 0:
            self.check_testrunner_result(cwd)
        return self
    
    def passed(self):
        """Return True if the return code is 0 (success), False otherwise."""
        return self.returncode == 0

@pytest.fixture(params=[Xcelium, Questa])
def simulator(request):
    """Return an instance of the classes specified by params."""
    return request.param()

@pytest.fixture
def svunit():
    """Return an SVUnit instance."""
    return SVUnit()

def simulator_from_name(name):
    if name in ['Xcelium', 'Questa']:
        return eval(name + '()')

def uvm_versions_from_config():
    config_file_name = os.getenv('BATHTUB_TEST_CFG', 'bathtub_test_cfg.yaml')
    config_file = open(config_file_name, 'r')
    test_config = yaml.safe_load(config_file)
    for simulator in test_config['simulators']:
        for uvm_version in simulator['uvm_versions']:
            yield {'simulator': simulator_from_name(simulator['name']), 'uvm_home': uvm_version, 'is_builtin': True}
            
    for uvm_version in test_config['uvm_versions']:
        for simulator in test_config['simulators']:
            yield {'simulator': simulator_from_name(simulator['name']), 'uvm_home': uvm_version, 'is_builtin': False}

@pytest.fixture(params=uvm_versions_from_config())
def uvm_version(request):
    return request.param
