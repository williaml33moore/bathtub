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
    working_uvm_home = tmp_path / uvm_version_name

    # Copy the entire UVM library locally and `chdir` there.
    # This is our working sim dir.
    shutil.copytree(uvm_version_path, working_uvm_home)
    os.chdir(working_uvm_home / 'examples' / 'integrated' / 'codec')
    sim_cwd_path = Path(os.getcwd())

    # Copy new and modified files into the local working sim dir.
    examples_src_path = Path(os.environ['BATHTUB_VIP_DIR']) / 'examples' / 'uvm_examples' / 'codec'
    shutil.copy(examples_src_path / 'Makefile_inc.xcelium', working_uvm_home / 'examples' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_run.xcelium', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.xcelium')
    
    # Run the codec simulation as-is.
    run_cmd = 'make -f Makefile.xcelium XCELIUMFLAGS=-uvmnocdnsextra clean test'
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)


def test_codec_with_bathtub(tmp_path, get_test_config):
    """Test UVM 1.2 codec example with Bathtub."""
    
    # Get the path to the correct UVM version download from our pytest test config.
    uvm_version_name = 'uvm-1.2'
    uvm_versions = get_test_config['uvm_versions']
    uvm_version_full_name = [v for v in uvm_versions if v.endswith(uvm_version_name)][0]
    uvm_version_path = Path(uvm_version_full_name)
    working_uvm_home = tmp_path / uvm_version_name

    # Copy the entire UVM library locally and `chdir` there.
    # This is our working sim dir.
    shutil.copytree(uvm_version_path, working_uvm_home)
    os.chdir(working_uvm_home / 'examples' / 'integrated' / 'codec')
    sim_cwd_path = Path(os.getcwd())

    # Copy new and modified files into the local working sim dir.
    examples_src_path = Path(os.environ['BATHTUB_VIP_DIR']) / 'examples' / 'uvm_examples' / 'codec'
    shutil.copy(examples_src_path / 'Makefile_inc.xcelium', working_uvm_home / 'examples' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_run.xcelium', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'tb_virtual_sequencer.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'tb_env.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'bathtub_test.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'codec_step_definitions.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'testlib.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'codec.feature', sim_cwd_path)
    
    # Run the codec simulation with Bathtub.
    run_cmd = 'make -f Makefile.xcelium XCELIUMFLAGS=-uvmnocdnsextra UVM_VERBOSITY=UVM_MEDIUM clean bathtub'
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)
