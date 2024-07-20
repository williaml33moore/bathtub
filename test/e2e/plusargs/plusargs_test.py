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

test_path = Path(os.path.dirname(__file__))

uvm_verbosity_map = {
    'UVM_NONE'   : 0,
    'UVM_LOW'    : 100,
    'UVM_MEDIUM' : 200,
    'UVM_HIGH'   : 300,
    'UVM_FULL'   : 400,
    'UVM_DEBUG'  : 500
}

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


@pytest.mark.parametrize("feature", ['many_scenarios.feature', 'many_scenarios_plus_background.feature'])
@pytest.mark.parametrize("start_value", [0, 2, 4])
def test_plusarg_bathtub_start(tmp_path, simulator, feature, start_value):
    """Test that +bathtub_start selects the scenario to start with"""

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_TESTNAME=plusarg_bathtub_start_stop_test',
        '+bathtub_start=' + str(start_value),
        ])
    assert simulator.run(tmp_path).passed()


@pytest.mark.parametrize("feature", ['many_scenarios.feature', 'many_scenarios_plus_background.feature'])
@pytest.mark.parametrize("stop_value", [2, 4])
def test_plusarg_bathtub_stop(tmp_path, simulator, feature, stop_value):
    """Test that +bathtub_stop selects the scenario to stop on"""

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_TESTNAME=plusarg_bathtub_start_stop_test',
        '+bathtub_stop=' + str(stop_value),
        ])
    assert simulator.run(tmp_path).passed()


@pytest.mark.parametrize("feature", ['many_scenarios.feature', 'many_scenarios_plus_background.feature'])
@pytest.mark.parametrize("start_value,stop_value", [(0, 2), (1, 3), (3, 5)])
def test_plusarg_bathtub_start_stop(tmp_path, simulator, feature, start_value, stop_value):
    """Test that +bathtub_start and +bathtub_stop select the scenarios to start and stop on"""

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_TESTNAME=plusarg_bathtub_start_stop_test',
        '+bathtub_start=' + str(start_value),
        '+bathtub_stop=' + str(stop_value),
        ])
    assert simulator.run(tmp_path).passed()


@pytest.mark.parametrize("uvm_verbosity", ['UVM_NONE', 'UVM_LOW', 'UVM_MEDIUM', 'UVM_HIGH', 'UVM_FULL'])
@pytest.mark.parametrize("bathtub_verbosity", ['UVM_NONE', 'UVM_LOW', 'UVM_MEDIUM', 'UVM_HIGH', 'UVM_FULL'])
def test_plusarg_bathtub_verbosity(tmp_path, simulator, uvm_verbosity, bathtub_verbosity):
    """Test that +bathtub_verbosity controls bathtub reports independently of +uvm_verbosity"""

    feature = 'simple.feature'

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_TESTNAME=plusarg_bathtub_verbosity_test',
        '+define+BATHTUB_VERBOSITY_TEST+',
        '+UVM_VERBOSITY=' + uvm_verbosity,
        '+bathtub_verbosity=' + bathtub_verbosity,
        ])
    assert simulator.run(tmp_path).passed()

    # Check UVM_VERBOSITY messages
    message_id = "uvm_verbosity_test"
    for verbosity_name, verbosity_value in uvm_verbosity_map.items():
        run_cmd = "grep '\\[{}\\] {},{}' {}".format(message_id, verbosity_name, verbosity_value, simulator.log)
        cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
        if uvm_verbosity_map[uvm_verbosity] >= verbosity_value:
            assert cp.returncode == 0, "Did not find expected message '{},{}' in +UVM_VERBOSITY={} log".format(verbosity_name, verbosity_value, uvm_verbosity)
        else:
            assert cp.returncode != 0, "Found unexpected message '{},{}' in +UVM_VERBOSITY={} log".format(verbosity_name, verbosity_value, uvm_verbosity)

    # Check bathtub_verbosity messages
    for message_id in ["bathtub_verbosity_test", "gherkin_parser_verbosity_test", "gherkin_document_runner_verbosity_test"]:
        for verbosity_name, verbosity_value in uvm_verbosity_map.items():
            run_cmd = "grep '\\[{}\\] {},{}' {}".format(message_id, verbosity_name, verbosity_value, simulator.log)
            cp = subprocess.run(run_cmd, shell=True, cwd=tmp_path)
            if uvm_verbosity_map[bathtub_verbosity] >= verbosity_value:
                assert cp.returncode == 0, "Did not find expected '{}' message '{},{}' in +bathtub_verbosity={} log".format(message_id, verbosity_name, verbosity_value, bathtub_verbosity)
            else:
                assert cp.returncode != 0, "Found unexpected '{}' message '{},{}' in +bathtub_verbosity={} log".format(message_id, verbosity_name, verbosity_value, bathtub_verbosity)


@pytest.mark.parametrize("feature", ['tags.feature'])
@pytest.mark.parametrize("include_tags,exclude_tags,expected_steps", [
    ([], [], ['step_100', 'step_200', 'step_300']),
    (['@feature_tag'], [], ['step_100', 'step_200', 'step_300']),
    (['@scenario_tag'], [], ['step_100']),
    (['@scenario_outline_tag'], [], ['step_200', 'step_300']),
    (['@examples_tag'], [], []), # Examples included but no scenario outline included
    (['@scenario_outline_tag', '@examples_tag'], [], ['step_200', 'step_300']),
    ([], ['@feature_tag'], []),
    ([], ['@scenario_tag'], ['step_200', 'step_300']),
    ([], ['@scenario_outline_tag'], ['step_100']),
    ([], ['@examples_tag'], ['step_100']),
    (['@scenario_tag'], ['@scenario_outline_tag'], ['step_100']),
    (['@scenario_outline_tag'], ['@scenario_tag'], ['step_200', 'step_300']),
    (['@scenario_tag'], ['@examples_tag'], ['step_100']),
    (['@examples_tag'], ['@scenario_tag'], []), # Examples included but no scenario outline included
    (['@scenario_outline_tag', '@examples_tag'], ['@scenario_tag'], ['step_200', 'step_300']),
    ])
def test_plusarg_bathtub_include_exclude(tmp_path, simulator, feature, include_tags, exclude_tags, expected_steps):
    """Test that +bathtub_include and +bathtub_exclude select tagged scenarios to run and skip"""

    include_args = " ".join(['+bathtub_include=' + tag for tag in include_tags])
    exclude_args = " ".join(['+bathtub_exclude=' + tag for tag in exclude_tags])
    expected_arg = '+expected=' + ','.join(expected_steps)

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_TESTNAME=plusarg_bathtub_include_exclude_test',
        include_args,
        exclude_args,
        expected_arg,
        ])
    assert simulator.run(tmp_path).passed()


@pytest.mark.parametrize("help", [True, False])
def test_plusarg_bathtub_help(tmp_path, simulator, help, feature_file_a):
    """Test that +bathtub_help prints a help message and exits."""

    help_arg = '+bathtub_help' if help else ''

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'plusargs.f'),
        '+bathtub_features=' + feature_file_a,
        '+UVM_TESTNAME=plusarg_bathtub_help_test',
        help_arg,
        ])
    assert simulator.run(tmp_path).passed()
