import subprocess
import pytest

class Simulator:
    """Abtraction of SystemVerilog Simulators"""
    def __init__(self):
        self.args = []
        self.returncode = -1
        self.uvm_flag = False
        self.uvm_home = '$UVM_HOME'
    
    def append_arg(self, arg):
        """Append a single argument to simulator command-line arguments."""
        self.args.append(arg)
        return self
    
    def extend_args(self, args):
        """Extend simulator command-line arguments with a list of new arguments."""
        self.args.extend(args)
        return self
    
    def uvm(self, uvm_home='$UVM_HOME'):
        """Enable UVM with the given UVM installation."""
        self.uvm_flag = True
        self.append_arg('-uvm')
        self.append_arg('-uvmhome ' + uvm_home)

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
    
    def uvm(self, uvm_home='$UVM_HOME'):
        super().uvm(uvm_home)
        # Xcelium requires additional arg when not using built-in UVM installation.
        self.append_arg('-uvmnocdnsextra')

class Questa(Simulator):
    """Abstraction of Questa simulator"""
    def __init__(self):
        super().__init__()
        self.binary = 'qrun'

class SVUnit:
    """Abstraction of runSVUnit script"""
    def __init__(self):
        self.simulator = None
        self.uvm_flag = False
        self.output_dir = None
        self.args = []
        self.script = 'runSVUnit'
        self.returncode = -1

    def sim(self, simulator):
        """Set the script's --sim option based on given simulator class."""
        sim_arg_values = {
            'Xcelium' : 'xcelium',
            'Questa' : 'qrun'
        }
        self.simulator = simulator
        self.args.append('--sim ' + sim_arg_values[self.simulator.name()])
        return self
    
    def uvm(self, uvm_flag=True):
        """Set the script's --uvm option"""
        self.uvm_flag = uvm_flag
        if self.uvm_flag:
            self.args.append('--uvm')
        if self.simulator.name() == 'Xcelium':
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
