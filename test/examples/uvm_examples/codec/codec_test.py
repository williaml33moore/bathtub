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

def test_codec_as_is(tmp_path, uvm_version):
    """Test UVM codec example as-is."""
    
    simulator = uvm_version['simulator']
    uvm_home = Path(uvm_version['uvm_home'])
    is_builtin = uvm_version['is_builtin']
    extra_opt = '-uvmnocdnsextra' if simulator.name() == 'Xcelium' and not is_builtin else ''

    if not (uvm_home / 'examples' / 'integrated' / 'codec').exists():
        # This version doesn't include the codec example.
        return

    working_uvm_home = tmp_path / 'uvm'

    # Copy the entire UVM library locally and `chdir` there.
    # This is our working sim dir.
    shutil.copytree(uvm_home, working_uvm_home)
    os.chdir(working_uvm_home / 'examples' / 'integrated' / 'codec')
    sim_cwd_path = Path(os.getcwd())

    # Copy new and modified files into the local working sim dir.
    examples_src_path = Path(os.environ['BATHTUB_VIP_DIR']) / 'examples' / 'uvm_examples' / 'codec'
    shutil.copy(examples_src_path / 'Makefile_inc.xcelium', working_uvm_home / 'examples' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_run.xcelium', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')

    subprocess.run('echo "{}" > uvm_version.txt'.format(uvm_version), shell=True)
    
    # Run the codec simulation as-is.
    if simulator.name() == 'Xcelium':
        is_uvm_1p0 = 'uvm-1.0' in uvm_version['uvm_home']
        run_cmd = 'make -f Makefile.xcelium XCELIUMFLAGS={} {} UVM_VERBOSITY=UVM_MEDIUM clean test'.format(extra_opt, 'UVM_VERSION_1_0=defined' if is_uvm_1p0 else '')
    elif simulator.name() == 'Questa':
        run_cmd = 'make -f Makefile.questa UVM_VERBOSITY=UVM_MEDIUM clean run'
    else:
        assert False, "Unknown simulator: {}".format(simulator.name())
    subprocess.run('echo "{}" > run_cmd.sh'.format(run_cmd), shell=True)
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)

@pytest.mark.parametrize("test_target", ["bathtub", "test_with_bathtub"])
def test_codec_with_bathtub(tmp_path, get_test_config, uvm_version, test_target):
    """Test UVM codec example with Bathtub."""
    
    simulator = uvm_version['simulator']
    uvm_home = Path(uvm_version['uvm_home'])
    is_builtin = uvm_version['is_builtin']
    extra_opt = '-uvmnocdnsextra' if simulator.name() == 'Xcelium' and not is_builtin else ''

    if not (uvm_home / 'examples' / 'integrated' / 'codec').exists():
        # This version doesn't include the codec example.
        return
    
    working_uvm_home = tmp_path / 'uvm'
    is_uvm_1p0 = 'uvm-1.0' in uvm_version['uvm_home']
    is_uvm_1p1 = 'uvm-1.1' in uvm_version['uvm_home']

    # Copy the entire UVM library locally and `chdir` there.
    # This is our working sim dir.
    shutil.copytree(uvm_home, working_uvm_home)
    os.chdir(working_uvm_home / 'examples' / 'integrated' / 'codec')
    sim_cwd_path = Path(os.getcwd())

    # Copy new and modified files into the local working sim dir.
    examples_src_path = Path(os.environ['BATHTUB_VIP_DIR']) / 'examples' / 'uvm_examples' / 'codec'
    shutil.copy(examples_src_path / 'Makefile_inc.xcelium', working_uvm_home / 'examples' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_run.xcelium', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.xcelium')
    shutil.copy(examples_src_path / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')
    shutil.copy(examples_src_path / 'Makefile_run.questa', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.questa')
    shutil.copy(examples_src_path / 'tb_virtual_sequencer.svh', sim_cwd_path)
    if is_uvm_1p0 or is_uvm_1p1:
        # UVM 1.0 and 1.1a do not contain uvm_coreservice_t so we need to use versions of these components that don't depend on it.
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'tb_env.svh', sim_cwd_path)
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'test.sv', sim_cwd_path)
    else:
        shutil.copy(examples_src_path / 'tb_env.svh', sim_cwd_path)
        shutil.copy(examples_src_path / 'test.sv', sim_cwd_path)
    shutil.copy(examples_src_path / 'bathtub_test.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'codec_step_definitions.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'testlib.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'codec.feature', sim_cwd_path)

    subprocess.run('echo "{}" > uvm_version.txt'.format(uvm_version), shell=True)
    
    # Run the codec simulation with Bathtub.
    if simulator.name() == 'Xcelium':
        is_uvm_1p0 = 'uvm-1.0' in uvm_version['uvm_home']
        run_cmd = 'make -f Makefile.xcelium XCELIUMFLAGS={} {} UVM_VERBOSITY=UVM_MEDIUM clean {}'.format(
            extra_opt, 'UVM_VERSION_1_0=defined' if is_uvm_1p0 else '', test_target)
    elif simulator.name() == 'Questa':
        # Questa and Xcelium Makefiles use different target names.
        questa_test_target = test_target
        if questa_test_target == 'test':
            questa_test_target = 'run'
        run_cmd = 'make -f Makefile.questa UVM_VERBOSITY=UVM_MEDIUM clean {}'.format(test_target)
    else:
        assert False, "Unknown simulator: {}".format(simulator.name())
    subprocess.run('echo "{}" > run_cmd.sh'.format(run_cmd), shell=True)
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)
