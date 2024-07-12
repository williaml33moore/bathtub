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

def test_compile_error(tmp_path, simulator):
    """Test that compilation error returns in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_nonexistent_file.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

def test_system_fatal(tmp_path, simulator):
    """Test that $fatal results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_system_fatal.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

def test_system_error(tmp_path, simulator):
    """Test that $error results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_system_error.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

def test_assert_failure(tmp_path, simulator):
    """Test that assertion failure results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_assert_failure.sv',
        ])
    simulator.run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"

def test_uvm_fatal(tmp_path, simulator):
    """Test that `uvm_fatal results in nonzero exit code"""

    simulator.extend_args([
        '$BATHTUB_VIP_DIR/test/simulators/test_uvm_fatal.sv',
        '-incdir $BATHTUB_VIP_DIR/test/resources/callbacks',
        ])
    simulator.uvm().run(tmp_path)
    print("Exited with return code {}".format(simulator.returncode))
    assert not simulator.passed(), "Expected nonzero return code"
