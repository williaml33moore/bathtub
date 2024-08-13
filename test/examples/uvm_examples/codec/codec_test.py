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

import pytest
import os.path
import os
from pathlib import Path
import subprocess
import shutil

test_path = Path(os.path.dirname(__file__))

def test_codec_as_is(tmp_path, get_test_config):
    """Test UVM 1.2 codec example as-is."""
    
    # Get the path to the correct UVM version download from our pytest test config.
    uvm_version_name = 'uvm-1.2'
    uvm_versions = get_test_config['uvm_versions']
    uvm_version_full_name = [v for v in uvm_versions if v.endswith(uvm_version_name)][0]
    uvm_version_path = Path(uvm_version_full_name)

    # Copy the entire UVM library locally and `chdir` there.
    # This is our working sim dir.
    shutil.copytree(uvm_version_path, tmp_path / uvm_version_name)
    os.chdir(tmp_path / uvm_version_name / 'examples' / 'integrated' / 'codec')

    # Copy new and modified files into the local working sim dir.
    shutil.copy(test_path / 'Makefile_inc.xcelium', Path('../../Makefile.xcelium'))
    shutil.copy(test_path / 'Makefile_run.xcelium', Path('Makefile.xcelium'))
    
    # Run the codec simulation as-is.
    run_cmd = 'make -f Makefile.xcelium XCELIUMFLAGS=-uvmnocdnsextra clean all'
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)
