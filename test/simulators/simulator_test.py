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
import subprocess

def test_compile_error(tmp_path, simulator):
    """Test that compilation error returns in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_compile_error_11235.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_compile_error_11235'
    run_cmd = "grep '\(\*E\|\*\* Error\).*{}' {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)

def test_system_fatal(tmp_path, simulator):
    """Test that $fatal results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_system_fatal.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_system_fatal_10101'
    run_cmd = "grep {} {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)

def test_system_error(tmp_path, simulator):
    """Test that $error results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_system_error.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_system_error_97531'
    run_cmd = "grep '{}' {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)

def test_assert_failure(tmp_path, simulator):
    """Test that assertion failure results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_assert_failure.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_assert_failure_24680'
    run_cmd = "grep {} {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)

    # Check log file for one of the assertion error keywords
    run_cmd = "grep -e ASRTST -e 'Assertion error' {}".format(simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Assertion error message not found in log file".format(magic_string)

def test_uvm_fatal(tmp_path, simulator):
    """Test that `uvm_fatal results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_uvm_fatal.sv',
        '-incdir $BATHTUB_VIP_DIR/test/resources/callbacks',
        ])
    simulator.uvm().run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_uvm_fatal_55572'
    run_cmd = "grep 'UVM_FATAL.*{}' {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)

def test_uvm_error(tmp_path, simulator):
    """Test that `uvm_error results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_uvm_error.sv',
        '-incdir $BATHTUB_VIP_DIR/test/resources/callbacks',
        ])
    simulator.uvm().run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

    # Check the log file for the magic string
    magic_string = 'test_uvm_error_12321'
    run_cmd = "grep 'UVM_ERROR.*{}' {}".format(magic_string, simulator.log)
    cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
    assert cp.returncode==0, "Magic string '{}' not found in log file".format(magic_string)
    