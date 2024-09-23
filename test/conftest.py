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
import yaml
import os
from simulator.xcelium import Xcelium
from simulator.questa import Questa
from svunit.svunit import SVUnit

test_config = None # Global config object

def init():
    global test_config
    config_file_name = os.getenv('BATHTUB_TEST_CFG', 'bathtub_test_cfg.yaml')
    config_file = open(config_file_name, 'r')
    test_config = yaml.safe_load(config_file)

init()

def legal_simulators():
    """List legal simulators."""
    return [Xcelium, Questa]

def list_of_simulators():
    """List legal simulators listed in the config file."""
    available_simulator_names = [s['name'] for s in test_config['simulators']]
    result = [s for s in legal_simulators() if s.__name__ in available_simulator_names]
    return result

@pytest.fixture(params=list_of_simulators())
def simulator(request):
    """Return an instance of the classes specified by params."""
    return request.param()

@pytest.fixture(params=list_of_simulators())
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
    if name in [s.__name__ for s in list_of_simulators()]:
        return eval(name + '()')

def uvm_versions_from_config():
    for simulator in test_config['simulators']:
        for uvm_version in simulator['uvm_versions']:
            opts = ''
            if simulator['name'] == 'Xcelium' and '1800.2-2020-1.0' in uvm_version:
                opts.append('+define+UVM_USE_PROCESS_CONTAINER')
            yield {'name': simulator['name'], 'uvm_home': uvm_version, 'is_builtin': True, 'opts': ' '.join(opts)}
            
    for uvm_version in test_config['uvm_versions']:
        for simulator in test_config['simulators']:
            opts = []
            if simulator['name'] == 'Xcelium':
                opts.append('-uvmnocdnsextra')
            if simulator['name'] == 'Xcelium' and '1800.2-2020-1.0' in uvm_version:
                opts.append('+define+UVM_USE_PROCESS_CONTAINER')
            yield {'name': simulator['name'], 'uvm_home': uvm_version, 'is_builtin': False, 'opts': ' '.join(opts)}

@pytest.fixture(params=uvm_versions_from_config())
def uvm_version(request):
    request.param['simulator'] = simulator_from_name(request.param['name'])
    return request.param

@pytest.fixture
def get_test_config():
    """Return the test config object."""
    return test_config
