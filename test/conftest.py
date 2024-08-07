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

import subprocess
import pytest
import yaml
import os
from simulator.xcelium import Xcelium
from simulator.questa import Questa
from svunit.svunit import SVUnit


@pytest.fixture(params=[Xcelium, Questa])
def simulator(request):
    """Return an instance of the classes specified by params."""
    return request.param()

@pytest.fixture(params=[Xcelium, Questa])
def create_simulator(request):
    """Return a factory that instantiates the classes specified by params."""
    # Pytest "factory as fixture" pattern.
    # Closure.
    def _create_simulator():
        return request.param()
    return _create_simulator

@pytest.fixture
def svunit():
    """Return an SVUnit instance."""
    return SVUnit()

def simulator_from_name(name):
    if name in ['Xcelium', 'Questa']:
        return eval(name + '()')

def uvm_versions_from_config():
    config_file_name = os.getenv('BATHTUB_TEST_CFG', 'bathtub_test_cfg.yaml')
    config_file = open(config_file_name, 'r')
    test_config = yaml.safe_load(config_file)
    for simulator in test_config['simulators']:
        for uvm_version in simulator['uvm_versions']:
            yield {'simulator': simulator_from_name(simulator['name']), 'uvm_home': uvm_version, 'is_builtin': True}
            
    for uvm_version in test_config['uvm_versions']:
        for simulator in test_config['simulators']:
            yield {'simulator': simulator_from_name(simulator['name']), 'uvm_home': uvm_version, 'is_builtin': False}

@pytest.fixture(params=uvm_versions_from_config())
def uvm_version(request):
    return request.param
