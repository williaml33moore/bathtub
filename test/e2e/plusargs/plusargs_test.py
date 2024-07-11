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

@pytest.fixture
def feature_file_a(tmp_path):
    """Create a feature file and return its filename"""
    file_name = 'a.feature'
    f = tmp_path / file_name
    content = \
    """
    Feature: A
    Scenario: AA
    Given AAA
    """
    f.write_text(content, encoding="utf-8")
    return file_name

@pytest.fixture
def feature_file_b(tmp_path):
    """Create a feature file and return its filename"""
    file_name = 'b.feature'
    f = tmp_path / file_name
    content = \
    """
    Feature: B
    Scenario: BB
    Given BBB
    """
    f.write_text(content, encoding="utf-8")
    return file_name

def test_plusarg_bathtub_features(tmp_path, feature_file_a, feature_file_b, simulator):
    """Test that +bathtub_features provides a list of feature files to run"""

    simulator.uvm()
    simulator.extend_args([
        '-f $BATHTUB_VIP_DIR/test/e2e/plusargs/plusargs.f',
        '+bathtub_features="' + feature_file_a + ' ' + feature_file_b + '"',
        '+UVM_TESTNAME=plusarg_bathtub_features_test',
        ])
    assert simulator.run(tmp_path).passed()


def test_plusarg_multiple_bathtub_features(tmp_path, feature_file_a, feature_file_b, simulator):
    """Test that multiple +bathtub_features plusargs provides a list of feature files to run"""

    simulator.uvm()
    simulator.extend_args([
        '-f $BATHTUB_VIP_DIR/test/e2e/plusargs/plusargs.f',
        '+bathtub_features=' + feature_file_a,
        '+bathtub_features=' + feature_file_b,
        '+UVM_TESTNAME=plusarg_bathtub_features_test',
        ])
    assert simulator.run(tmp_path).passed()
    

def test_plusarg_bathtub_dryrun(tmp_path, feature_file_a, simulator):
    """Test that +bathtub_dryrun parses the feature file without running it"""

    simulator.uvm()
    simulator.extend_args([
        '-f $BATHTUB_VIP_DIR/test/e2e/plusargs/plusargs.f',
        '+bathtub_features=' + feature_file_a,
        '+bathtub_dryrun',
        '+UVM_TESTNAME=plusarg_bathtub_dryrun_test',
        ])
    assert simulator.run(tmp_path).passed()