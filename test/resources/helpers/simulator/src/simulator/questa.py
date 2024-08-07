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

from simulator.simulator import Simulator
import subprocess

class Questa(Simulator):
    """Abstraction of Questa simulator"""
    def __init__(self):
        super().__init__()
        self.binary = 'qrun'
        self.log = 'qrun.log'

    def run(self, cwd='.'):
        """Run the simulator then do additional result checks."""
        super().run(cwd)
        if self.returncode != 0:
            # Simulator returned nonzero, indicating a problem
            return self
        
        # Simulator returned, so do additional log checks
        run_cmd = "perl $BATHTUB_VIP_DIR/test/scripts/qrun_result.pl"
        self.returncode = subprocess.run(run_cmd, shell=True, cwd=cwd).returncode
        return self
