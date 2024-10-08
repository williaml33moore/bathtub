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
    is_uvm_1p0 = 'uvm-1.0' in uvm_version['uvm_home']
    examples_src_path = Path(os.environ['BATHTUB_VIP_DIR']) / 'examples' / 'uvm_examples' / 'codec'
    if is_uvm_1p0:
        # UVM-1.0 needs different makefiles.
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'Makefile_inc.ius', working_uvm_home / 'examples' / 'Makefile.ius')
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')
    else:
        shutil.copy(examples_src_path / 'Makefile_inc.ius', working_uvm_home / 'examples' / 'Makefile.ius')
        shutil.copy(examples_src_path / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')
    shutil.copy(examples_src_path / 'Makefile_run.ius', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.ius')
    shutil.copy(examples_src_path / 'Makefile_run.questa', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.questa')

    subprocess.run('echo "{}" > uvm_version.txt'.format(uvm_version), shell=True)
    
    # Run the codec simulation as-is.
    if simulator.name() == 'Xcelium':
        run_cmd = 'make -f Makefile.ius UVM_VERBOSITY=UVM_MEDIUM clean test'
    elif simulator.name() == 'Questa':
        run_cmd = 'make -f Makefile.questa UVM_VERBOSITY=UVM_MEDIUM clean run'
    else:
        assert False, "Unknown simulator: {}".format(simulator.name())
    subprocess.run('echo "{}" > run_cmd.sh'.format(run_cmd), shell=True)
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)

@pytest.mark.parametrize("test_target", ["bathtub_test", "test_with_bathtub"])
def test_codec_with_bathtub(tmp_path, get_test_config, uvm_version, test_target):
    """Test UVM codec example with Bathtub."""
    
    simulator = uvm_version['simulator']
    uvm_home = Path(uvm_version['uvm_home'])

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
    if is_uvm_1p0:
        # UVM-1.0 needs different makefiles.
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'Makefile_inc.ius', working_uvm_home / 'examples' / 'Makefile.ius')
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')
    else:
        shutil.copy(examples_src_path / 'Makefile_inc.ius', working_uvm_home / 'examples' / 'Makefile.ius')
        shutil.copy(examples_src_path / 'Makefile_inc.questa', working_uvm_home / 'examples' / 'Makefile.questa')
    shutil.copy(examples_src_path / 'Makefile_run.ius', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.ius')
    shutil.copy(examples_src_path / 'Makefile_run.questa', working_uvm_home / 'examples' / 'integrated' / 'codec' / 'Makefile.questa')
    if is_uvm_1p0 or is_uvm_1p1:
        # Use these files for UVM 1.0 and 1.1.
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'bathtub_test.svh', sim_cwd_path)
        shutil.copy(examples_src_path / 'uvm-1.0p1' / 'codec_step_definitions.svh', sim_cwd_path)
    else:
        # Use these files for UVM 1.2, UVM 2017, and newer.
        shutil.copy(examples_src_path / 'bathtub_test.svh', sim_cwd_path)
        shutil.copy(examples_src_path / 'codec_step_definitions.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'testlib.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'tb_virtual_sequencer.svh', sim_cwd_path)
    shutil.copy(examples_src_path / 'codec.feature', sim_cwd_path)

    subprocess.run('echo "{}" > uvm_version.txt'.format(uvm_version), shell=True)
    
    # Run the codec simulation with Bathtub.
    if simulator.name() == 'Xcelium':
        run_cmd = 'make -f Makefile.ius UVM_VERBOSITY=UVM_MEDIUM clean {}'.format(test_target)
    elif simulator.name() == 'Questa':
        # Questa and Xcelium Makefiles use different target names.
        questa_test_target = test_target
        if questa_test_target == 'test':
            questa_test_target = 'run'
        run_cmd = 'make -f Makefile.questa UVM_VERBOSITY=UVM_MEDIUM clean {}'.format(questa_test_target)
    else:
        assert False, "Unknown simulator: {}".format(simulator.name())
    subprocess.run('echo "{}" > run_cmd.sh'.format(run_cmd), shell=True)
    cp = subprocess.run(run_cmd, shell=True)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)

def test_run_me(tmp_path):
    """Test the entire example run_me.sh script."""
    run_cmd = 'sh -f $BATHTUB_VIP_DIR/examples/uvm_examples/codec/run_me.sh'
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)
