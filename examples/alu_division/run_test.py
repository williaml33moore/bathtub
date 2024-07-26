import subprocess
import os.path
import pytest

@pytest.fixture(params=["run_test.sh", "qrun_test.sh"])
def run_cmd(request):
    """Return absolute path to run script."""
    cwd = os.path.dirname(__file__)
    run_cmd_param = request.param
    return os.path.join(cwd, run_cmd_param)

def test(tmp_path, run_cmd):
    assert subprocess.run(run_cmd, shell=True, cwd=tmp_path).returncode == 0

def test_xrun_with_dash_f_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    xrun \
    -uvm \
    -uvmhome $XCELIUM_HOME/tools.lnx86/methodology/UVM/CDNS-1.2 \
    -f $BATHTUB_VIP_DIR/src/bathtub_vip.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

def test_xrun_with_dash_F_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    xrun \
    -uvm \
    -uvmhome $XCELIUM_HOME/tools.lnx86/methodology/UVM/CDNS-1.2 \
    -F $BATHTUB_VIP_DIR/src/bathtub_vip_rel.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

def test_xrun_with_wrong_dash_f_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    xrun \
    -uvm \
    -uvmhome $XCELIUM_HOME/tools.lnx86/methodology/UVM/CDNS-1.2 \
    -f $BATHTUB_VIP_DIR/src/bathtub_vip.F \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    # This one should fail
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode != 0

def test_xrun_with_wrong_dash_F_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    xrun \
    -uvm \
    -uvmhome $XCELIUM_HOME/tools.lnx86/methodology/UVM/CDNS-1.2 \
    -F $BATHTUB_VIP_DIR/src/bathtub_vip.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

def test_qrun_with_dash_f_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    qrun \
    -uvm \
    -uvmhome $MTI_HOME/verilog_src/uvm-1.2 \
    -f $BATHTUB_VIP_DIR/src/bathtub_vip.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

def test_qrun_with_dash_F_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    qrun \
    -uvm \
    -uvmhome $MTI_HOME/verilog_src/uvm-1.2 \
    -F $BATHTUB_VIP_DIR/src/bathtub_vip_rel.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

def test_qrun_with_wrong_dash_f_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    qrun \
    -uvm \
    -uvmhome $MTI_HOME/verilog_src/uvm-1.2 \
    -f $BATHTUB_VIP_DIR/src/bathtub_vip.F \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    # This one should fail
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode != 0

def test_qrun_with_wrong_dash_F_option(tmp_path):
    cmd = '''
    cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
    qrun \
    -uvm \
    -uvmhome $MTI_HOME/verilog_src/uvm-1.2 \
    -F $BATHTUB_VIP_DIR/src/bathtub_vip.f \
    -incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
    $BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
    $BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
    +UVM_TESTNAME=bathtub_test \
    +UVM_VERBOSITY=UVM_HIGH \
    #
    '''
    assert subprocess.run(cmd, shell=True, cwd=tmp_path).returncode == 0

if __name__ == "__main__":
    test()
