import subprocess
import pytest

class Simulator:
    def __init__(self):
        self.args = []
        self.returncode = -1
        self.binary = 'xrun'
        self.name = 'xcelium'
    
    def append_args(self, arg):
        self.args.append(arg)
        return self

    def run(self, cwd='.'):
        run_cmd = " ".join([self.binary] + self.args)
        self.returncode = subprocess.run(run_cmd, shell=True, cwd=cwd).returncode
        return self
    
    def passed(self):
        return self.returncode == 0
    

class SVUnit:
    def __init__(self):
        self.simulator = None
        self.uvm_flag = False
        self.output_dir = None
        self.args = []
        self.script = 'runSVUnit'
        self.returncode = -1

    def sim(self, simulator):
        self.simulator = simulator
        self.args.append('--sim ' + self.simulator.name)
        return self
    
    def uvm(self, uvm_flag=True):
        self.uvm_flag = uvm_flag
        if self.uvm_flag:
            self.args.append('--uvm')
        if self.simulator.name == 'xcelium':
            self.args.append("--c_arg '-uvmnocdnsextra'")
        return self
    
    def out(self, output_dir):
        self.output_dir = output_dir
        self.args.append('--out ' + str(output_dir))
        return self
    
    def run(self, cwd='.'):        
        svunit_cmd = " ".join([self.script] + self.args)
        self.returncode = subprocess.run(svunit_cmd, shell=True, cwd=cwd).returncode
        if self.returncode == 0:
            checker_cmd = "grep '^INFO.*testrunner.*PASSED' " + str(self.output_dir) + "/run.log"
            self.returncode = subprocess.run(checker_cmd, shell=True, cwd=cwd).returncode
        return self
    
    def passed(self):
        return self.returncode == 0


@pytest.fixture
def simulator():
    sim = Simulator()
    return sim

def test_xrun(tmp_path):
    vip_cmd = "xrun $BATHTUB_VIP_DIR/vip-spec.sv"
    assert subprocess.run(vip_cmd, shell=True, cwd=tmp_path).returncode == 0
    svunit_cmd = "runSVUnit --sim xrun --uvm --c_arg '-uvmnocdnsextra' --out " + str(tmp_path)
    # svunit_cmd += " -r +UVM_VERBOSITY=UVM_HIGH"
    assert subprocess.run(svunit_cmd, shell=True).returncode == 0
    checker_cmd = "grep '^INFO.*testrunner.*PASSED' " + str(tmp_path) + "/run.log"
    assert subprocess.run(checker_cmd, shell=True).returncode == 0

def test_qrun(tmp_path):
    vip_cmd = "qrun $BATHTUB_VIP_DIR/vip-spec.sv"
    assert subprocess.run(vip_cmd, shell=True, cwd=tmp_path).returncode == 0
    svunit_cmd = "runSVUnit --sim qrun --uvm --out " + str(tmp_path)
    # svunit_cmd += " -r +UVM_VERBOSITY=UVM_HIGH"
    assert subprocess.run(svunit_cmd, shell=True).returncode == 0
    checker_cmd = "grep '^# INFO.*testrunner.*PASSED' " + str(tmp_path) + "/run.log"
    assert subprocess.run(checker_cmd, shell=True).returncode == 0

def test_all(tmp_path, simulator):
    assert simulator.append_args('$BATHTUB_VIP_DIR/vip-spec.sv').run(tmp_path).passed()
    assert SVUnit().sim(simulator).uvm().out(tmp_path).run().passed()
