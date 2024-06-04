import subprocess
# import os.path
import pytest

# @pytest.fixture(params=[""])
# def run_cmd(request):
#     """Return absolute path to run script."""
#     cwd = os.path.dirname(__file__)
#     run_cmd_param = request.param
#     return os.path.join(cwd, run_cmd_param)

def test(tmp_path):
    vip_cmd = "xrun $BATHTUB_VIP_DIR/vip-spec.sv"
    assert subprocess.run(vip_cmd, shell=True, cwd=tmp_path).returncode == 0
    svunit_cmd = "xrun $BATHTUB_VIP_DIR/vip-spec.sv && runSVUnit -U -o " + str(tmp_path)
    assert subprocess.run(svunit_cmd, shell=True).returncode == 0

if __name__ == "__main__":
    test()
