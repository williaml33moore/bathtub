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

if __name__ == "__main__":
    test()
