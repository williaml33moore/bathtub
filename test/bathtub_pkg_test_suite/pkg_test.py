import subprocess
import pytest

def test_xrun(tmp_path):
    vip_cmd = "xrun $BATHTUB_VIP_DIR/vip-spec.sv"
    assert subprocess.run(vip_cmd, shell=True, cwd=tmp_path).returncode == 0
    svunit_cmd = "runSVUnit --sim xrun --uvm --c_arg '-uvmnocdnsextra' --out " + str(tmp_path)
    assert subprocess.run(svunit_cmd, shell=True).returncode == 0
    checker_cmd = "grep '^INFO.*testrunner.*PASSED' " + str(tmp_path) + "/run.log"
    assert subprocess.run(checker_cmd, shell=True).returncode == 0

def test_qrun(tmp_path):
    vip_cmd = "qrun $BATHTUB_VIP_DIR/vip-spec.sv"
    assert subprocess.run(vip_cmd, shell=True, cwd=tmp_path).returncode == 0
    svunit_cmd = "runSVUnit --sim qrun --uvm --out " + str(tmp_path)
    assert subprocess.run(svunit_cmd, shell=True).returncode == 0
    checker_cmd = "grep '^# INFO.*testrunner.*PASSED' " + str(tmp_path) + "/run.log"
    assert subprocess.run(checker_cmd, shell=True).returncode == 0
