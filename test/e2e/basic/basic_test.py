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
from pathlib import Path
import subprocess
import shutil

test_path = Path(os.path.dirname(__file__))

@pytest.mark.parametrize("testname, features", [('basic_test', ['basic.feature']),
                                                ('basic_sequence_test', ['basic.feature']),
                                                ('basic_sequence_start_test', ['basic.feature']),
                                                ])
def test_basic_e2e(tmp_path, uvm_version, testname, features):
    """Basic end-to-end test"""

    simulator = uvm_version['simulator']
    uvm_home = uvm_version['uvm_home']
    version_opts = uvm_version['opts']

    simulator.uvm(uvm_home).extend_args([
        version_opts,
        '-f ' + str(test_path / 'basic.f'),
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/tests',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/step_defs',
        '-incdir $BATHTUB_VIP_DIR/test/resources/environments',
        '$BATHTUB_VIP_DIR/test/resources/testbenches/basic_tb_top.sv',
        '+UVM_TESTNAME=' + testname,
        '+bathtub_features=' + '"' + " ".join([str(test_path / 'features' /  feature) for feature in features]) + '"',
        ])
    assert simulator.run(tmp_path).passed()

@pytest.mark.parametrize("testname, features", [('basic_test', ['undefined_step.feature']),
                                                ('basic_test', ['undefined_steps.feature'])])
def test_basic_snippet_e2e(tmp_path, create_simulator, testname, features):
    """Test undefined steps produce a snippet"""
    simulator = create_simulator()
    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'basic.f'),
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/tests',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/step_defs',
        '-incdir $BATHTUB_VIP_DIR/test/resources/environments',
        '$BATHTUB_VIP_DIR/test/resources/testbenches/basic_tb_top.sv',
        '+UVM_TESTNAME=' + testname,
        '+bathtub_features=' + '"' + " ".join([str(test_path / 'features' /  feature) for feature in features]) + '"',
        ])
    assert not simulator.run(tmp_path).passed() # Expect failure

    # Check log file for expected error message
    error_string = '\\UVM_ERROR.*[assert_step_resource_is_not_null\\]'
    run_cmd = "grep {} {}".format(error_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Expected error string '{}' not found in log file".format(error_string)

@pytest.mark.parametrize("testname, features", [('basic_test', ['undefined_step.feature']),
                                                ('basic_test', ['undefined_steps.feature'])])
def test_basic_working_snippet_e2e(tmp_path, create_simulator, testname, features):
    """Test undefined steps produce a working snippet"""
    simulator = create_simulator()

    # Run test the first time with undefined steps to produce a snippet
    test_basic_snippet_e2e(tmp_path, create_simulator, testname, features)

    # Save off log file and snippets file
    shutil.copyfile(tmp_path / simulator.log, tmp_path / 'first_run.log')
    new_snippets_filename = 'new_snippets.svh'
    shutil.copyfile(tmp_path / 'bathtub_snippets.svh', tmp_path / new_snippets_filename)

    # Append new snippets file to step def file
    new_step_defs_filename = 'new_step_def_seqs.svh'
    new_step_defs_path = Path(tmp_path / new_step_defs_filename)
    if new_step_defs_path.exists():
        new_step_defs_path.unlink()
    append_str = '`include "' + new_snippets_filename + '"'
    sed_cmd = "$a" + append_str
    run_cmd = "sed -e '" + sed_cmd + "' " + str(test_path / 'basic_step_def_seqs.svh') + " > " + str(new_step_defs_path)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Error with shell command: {}".format(run_cmd)

    # Run test again with new snippet

    simulator = create_simulator()
    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'basic.f'),
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/tests',
        '-incdir $BATHTUB_VIP_DIR/test/e2e/basic/step_defs',
        '-incdir $BATHTUB_VIP_DIR/test/resources/environments',
        '$BATHTUB_VIP_DIR/test/resources/testbenches/basic_tb_top.sv',
        '+UVM_TESTNAME=' + testname,
        '+bathtub_features=' + '"' + " ".join([str(test_path / 'features' /  feature) for feature in features]) + '"',
        '+define+BASIC_STEP_DEF_SEQS=' + str(new_step_defs_path) + '', # New step defs
        '+uvm_set_severity="uvm_test_top.env.seqr,PENDING,UVM_ERROR,UVM_WARNING"', # Demote PENDING error to warning
        ])
    assert simulator.run(tmp_path).passed() # Expect passing

    # Check log file for expected warning message
    warning_string = '\\UVM_WARNING.*[PENDING\\]'
    run_cmd = "grep {} {}".format(warning_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Expected warning string '{}' not found in log file".format(warning_string)

@pytest.mark.parametrize("testname, features", [('basic_test', ['undefined_step.feature']),
                                                ('basic_test', ['undefined_steps.feature'])])
def test_snippet_p_sequencer_e2e(tmp_path, create_simulator, testname, features):
    """Test snippet declares a p_sequencer"""
    simulator = create_simulator()

    # Run test the first time with undefined steps to produce a snippet
    test_basic_snippet_e2e(tmp_path, create_simulator, testname, features)

    # Check snippet for p_sequencer declaration
    snippets_filename = 'bathtub_snippets.svh'
    snippets_path = Path(tmp_path / snippets_filename)
    expected_string = "'^ *`uvm_declare_p_sequencer(uvm_sequencer)'"
    run_cmd = "grep {} {}".format(expected_string, str(snippets_path))
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "{}\nExpected declaration string '{}' not found in snippets file {}".format(run_cmd, expected_string, snippets_filename)

