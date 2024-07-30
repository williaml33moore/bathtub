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

test_path = Path(os.path.dirname(__file__))

@pytest.mark.parametrize("testname, feature", [('simple_test', 'step_definition_interface_0.feature')])
def test_step_definition_interface_e2e(tmp_path, simulator, testname, feature):
    """Test that step definition interface methods function correctly"""

    simulator.uvm().extend_args([
        '-f ' + str(test_path / 'step_definition_interface.f'),
        '+UVM_TESTNAME=' + testname,
        '+bathtub_features=' + str(test_path / 'features' /  feature),
        '+UVM_VERBOSITY=UVM_HIGH',
        '+bathtub_verbosity=UVM_HIGH',
        ])
    assert simulator.run(tmp_path).passed()