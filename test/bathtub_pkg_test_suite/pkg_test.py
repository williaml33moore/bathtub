import subprocess
import pytest

class Simulator:
    def __init__(self):
        self.args = []
        self.returncode = -1
    
    def append_args(self, arg):
        self.args.append(arg)
        return self

    def run(self, cwd='.'):
        run_cmd = " ".join([self.binary] + self.args)
        self.returncode = subprocess.run(run_cmd, shell=True, cwd=cwd).returncode
        return self
    
    def passed(self):
        return self.returncode == 0
    
    def name(self):
        return self.__class__.__name__

class Xcelium(Simulator):
    def __init__(self):
        super().__init__()
        self.binary = 'xrun'

class Questa(Simulator):
    def __init__(self):
        super().__init__()
        self.binary = 'qrun'

class SVUnit:
    def __init__(self):
        self.simulator = None
        self.uvm_flag = False
        self.output_dir = None
        self.args = []
        self.script = 'runSVUnit'
        self.returncode = -1

    def sim(self, simulator):
        sim_arg_values = {
            'Xcelium' : 'xcelium',
            'Questa' : 'qrun'
        }
        self.simulator = simulator
        self.args.append('--sim ' + sim_arg_values[self.simulator.name()])
        return self
    
    def uvm(self, uvm_flag=True):
        self.uvm_flag = uvm_flag
        if self.uvm_flag:
            self.args.append('--uvm')
        if self.simulator.name() == 'Xcelium':
            self.args.append("--c_arg '-uvmnocdnsextra'")
        return self
    
    def out(self, output_dir):
        self.output_dir = output_dir
        self.args.append('--out ' + str(output_dir))
        return self
    
    def check_testrunner_result(self, cwd='.'):
        if self.simulator.name() == 'Questa':
            checker_cmd = "grep '^# INFO.*testrunner.*PASSED' " + str(self.output_dir) + "/run.log"
        else:
            checker_cmd = "grep '^INFO.*testrunner.*PASSED' " + str(self.output_dir) + "/run.log"
        self.returncode = subprocess.run(checker_cmd, shell=True, cwd=cwd).returncode
    
    def run(self, cwd='.'):        
        svunit_cmd = " ".join([self.script] + self.args)
        self.returncode = subprocess.run(svunit_cmd, shell=True, cwd=cwd).returncode
        if self.returncode == 0:
            self.check_testrunner_result(cwd)
        return self
    
    def passed(self):
        return self.returncode == 0

@pytest.fixture(params=[Xcelium, Questa])
def simulator(request):
    """Return an instance of the classes specified by params."""
    return request.param()

def test_all(tmp_path, simulator):
    assert simulator.append_args('$BATHTUB_VIP_DIR/vip-spec.sv').run(tmp_path).passed()
    assert SVUnit().sim(simulator).uvm().out(tmp_path).run().passed()
