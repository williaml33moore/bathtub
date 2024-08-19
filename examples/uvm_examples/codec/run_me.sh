#!/bin/sh

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


Usage=<<'EOF'
=====
> This script automatically runs through the process of applying Bathtub to the UVM 1.2 codec example.
It downloads your own personal UVM 1.2 installation, gets it running as-is, adds Bathtub by copying files from this directory, then runs everything all together.
You may need to customize this script for your environment.
See `README.md` for details.
This script is intended to be living documentation that is operational but also human-readable, so you can understand the steps involved.
> 
> The script requires you have environment variable $BATHTUB_VIP_DIR which contains the path to your Bathtub installation.
Run this script from a suitable directory that you have read and write privileges for, e.g., your home directory:
```
sh -f $BATHTUB_VIP_DIR/examples/uvm_examples/codec/run_me.sh
```
EOF


function info() {
    echo "$0 (${BASH_LINENO[0]}):" $*
}

function fatal() {
    EXIT_CODE=$?
    echo "$0 (${BASH_LINENO[0]}):" $*
    exit $EXIT_CODE
}

# Assert that $BATHUB_VIP_DIR is defined and valid
#
test ${BATHTUB_VIP_DIR:?"Environment variable BATHTUB_VIP_DIR is undefined"}
test -d $BATHTUB_VIP_DIR || fatal "Environment variable BATHTUB_VIP_DIR does not contain a valid directory: $BATHTUB_VIP_DIR"

info "Create the personal working directory"
PERSONAL_DIR=bathtub_codec_example
mkdir -p $PERSONAL_DIR
cd $PERSONAL_DIR

info "Download and install the UVM 1.2 reference implementation to a personal working directory"
# ===
curl https://accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz -o uvm-1.2.tar.gz
gunzip -c uvm-1.2.tar.gz | tar xf -

info "Define some directory variables"
USER_UVM_HOME=`pwd`/uvm-1.2
CODEC_WORKING_DIR=$USER_UVM_HOME/examples/integrated/codec
BATHTUB_CODEC_SRC=$BATHTUB_VIP_DIR/examples/uvm_examples/codec

info "Change to your codec working directory"
cd $CODEC_WORKING_DIR

info "Run Incisive/Xcelium on the codec example as-is"
echo # ---
make -f Makefile.ius test

info "If it fails, make a backup of ../../Makefile.ius, then edit the original to make the simulation run and pass."
cp ../../Makefile.ius ../../Makefile.ius-BACKUP

info "E.g., add '-uvmnocdnsextra' so Cadence tools can run with a non-Cadence UVM installation."
sed -i -e '/^IUS =/ s/\(.*\)/\1 -uvmnocdnsextra/' ../../Makefile.ius

info "E.g., change 'irun.log' to 'xrun.log' so the results checker can find the log file."
sed -i -e 's/irun\.log/xrun\.log/g' ../../Makefile.ius

info "Try Incisive/Xcelium again. It should pass now."
echo
make -f Makefile.ius test || fatal "Incisive/Xcelium failed to run codec as-is. Check your environment and makefiles."

info "Run Questa on the codec example as-is"
echo # ---
make -f Makefile.questa run

info "If it fails, make a backup of ../../Makefile.questa, then edit the original to make the simulation run and pass."
cp ../../Makefile.questa ../../Makefile.questa-BACKUP

info "E.g., change '+acc=rmb' to '+acc=rb'"
sed -i -e 's/\+acc=rmb/\+acc=rb/' ../../Makefile.questa

info "Try Questa again. It should pass now."
echo
make -f Makefile.questa run || fatal "Questa failed to run codec as-is. Check your environment and makefiles."

# info "Run VCS on the codec example as-is"
# echo # ---
# make -f Makefile.vcs test
#
# info "If it fails, make a backup of ../../Makefile.vcs, then edit the original to make the simulation run and pass."
# cp ../../Makefile.vcs ../../Makefile.vcs-BACKUP
#
# info "Make any changes"
# sed -i -e '' ../../Makefile.vcs
#
# info "Try VCS again. It should pass now."
# echo
# make -f Makefile.vcs test || fatal "VCS failed to run codec as-is. Check your environment and makefiles.

info "Apply Bathtub"
# ===

info "Copy files from the Bathtub examples source directory to your working directory:"
info "* Bathtub test"
info "* Test library file (make a backup first)"
info "* Virtual sequencer"
info "* Gherkin feature file"
info "* Step definitions"
cp $CODEC_WORKING_DIR/testlib.svh $CODEC_WORKING_DIR/testlib.svh-BACKUP
cp \
    $BATHTUB_CODEC_SRC/bathtub_test.svh \
    $BATHTUB_CODEC_SRC/testlib.svh \
    $BATHTUB_CODEC_SRC/tb_virtual_sequencer.svh \
    $BATHTUB_CODEC_SRC/codec.feature \
    $BATHTUB_CODEC_SRC/codec_step_definitions.svh \
    $CODEC_WORKING_DIR

info "Run Incisive/Xcelium"
# ---

info "Make a backup of your Incisive/Xcelium makefile, then copy the 'run' makefile from the Bathtub examples source directory to your working directory."
cp $CODEC_WORKING_DIR/Makefile.ius $CODEC_WORKING_DIR/Makefile.ius-BACKUP
cp $BATHTUB_CODEC_SRC/Makefile_run.ius $CODEC_WORKING_DIR/Makefile.ius

info "Run the original 'test' with the new Bathtub testbench in Incisive/Xcelium."
echo
make -f Makefile.ius test_with_bathtub || fatal "Incisive/Xcelium failed to run 'test' with the Bathtub testbench. Check the log file."

info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in Incisive/Xcelium."
echo
make -f Makefile.ius bathtub_test || fatal "Incisive/Xcelium failed to run 'bathtub_test.' Check the log file."
info "Congratulations! You have successfully run Bathtub in Incisive/Xcelium."

info "Run Questa"
# ---

info "Make a backup of your Questa makefile, then copy the 'run' makefile from the Bathtub examples source directory to your working directory."
cp $CODEC_WORKING_DIR/Makefile.questa $CODEC_WORKING_DIR/Makefile.questa-BACKUP
cp $BATHTUB_CODEC_SRC/Makefile_run.questa $CODEC_WORKING_DIR/Makefile.questa

info "Run the original 'test' with the new Bathtub testbench in Questa."
echo
make -f Makefile.questa test_with_bathtub || fatal "Questa failed to run 'test' with the Bathtub testbench. Check the log file."

info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in Questa."
echo
make -f Makefile.questa bathtub_test || fatal "Questa failed to run 'bathtub_test.' Check the log file."
info "Congratulations! You have successfully run Bathtub in Questa."

# info "Run VCS"
# # ---
#
# info "Make a backup of your VCS makefile, then copy the 'run' makefile from the Bathtub examples source directory to your working directory."
# cp $CODEC_WORKING_DIR/Makefile.vcs $CODEC_WORKING_DIR/Makefile.vcs-BACKUP
# cp $BATHTUB_CODEC_SRC/Makefile_run.vcs $CODEC_WORKING_DIR/Makefile.vcs
#
# info "Run the original 'test' with the new Bathtub testbench in VCS."
# echo
# make -f Makefile.vcs test_with_bathtub || fatal "VCS failed to run 'test' with the Bathtub testbench. Check the log file."
#
# info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in VCS."
# echo
# make -f Makefile.vcs bathtub_test || fatal "VCS failed to run 'bathtub_test.' Check the log file."
# info "Congratulations! You have successfully run Bathtub in VCS."
