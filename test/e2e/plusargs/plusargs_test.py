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

def test_plusarg_bathtub_features(tmp_path, simulator):
    """Test that +bathtub_features provides a list of feature files to run"""

    f = tmp_path / 'a.feature'
    content = \
    """
    Feature: A
    Scenario: AA
    Given AAA
    """
    f.write_text(content, encoding="utf-8")

    f = tmp_path / 'b.feature'
    content = \
    """
    Feature: B
    Scenario: BB
    Given BBB
    """
    f.write_text(content, encoding="utf-8")

    simulator.uvm()
    simulator.extend_args([
        '-f $BATHTUB_VIP_DIR/test/e2e/plusargs/plusargs.f',
        '+bathtub_features="a.feature b.feature"',
        ])
    assert simulator.run(tmp_path).passed()