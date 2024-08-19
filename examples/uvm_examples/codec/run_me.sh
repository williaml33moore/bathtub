#!/bin/sh

function info() {
    echo "$0 (${BASH_LINENO[0]}):" $*
}

PERSONAL_DIR=bathtub_codec_example

info "Download and install the UVM 1.2 reference implementation to a personal directory"
# ===
mkdir -p $PERSONAL_DIR
cd $PERSONAL_DIR
curl https://accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz -o uvm-1.2.tar.gz
gunzip -c uvm-1.2.tar.gz | tar xf -

info "Define some directory variables"
USER_UVM_HOME=`pwd`/uvm-1.2
CODEC_WORKING_DIR=$USER_UVM_HOME/examples/integrated/codec
BATHTUB_CODEC_SRC=$BATHTUB_VIP_DIR/examples/uvm_examples/codec

info "Change to your working directory"
cd $CODEC_WORKING_DIR

info "Run Incisive/Xcelium"
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
make -f Makefile.ius test || exit

info "Run Questa"
echo # ---
make -f Makefile.questa run

info "If it fails, make a backup of ../../Makefile.questa, then edit the original to make the simulation run and pass."
cp ../../Makefile.questa ../../Makefile.questa-BACKUP

info "E.g., change '+acc=rmb' to '+acc=rb'"
sed -i -e 's/\+acc=rmb/\+acc=rb/' ../../Makefile.questa

info "Try Questa again. It should pass now."
echo
make -f Makefile.questa run || exit

# info "Run VCS"
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
# make -f Makefile.vcs test || exit

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
cp Makefile.ius Makefile.ius-BACKUP
cp $BATHTUB_CODEC_SRC/Makefile_run.ius $CODEC_WORKING_DIR/Makefile.ius

info "Run the original 'test' with the new Bathtub testbench in Incisive/Xcelium."
echo
make -f Makefile.ius test_with_bathtub || exit

info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in Incisive/Xcelium."
echo
make -f Makefile.ius bathtub_test || exit
info "Congratulations!"

info "Run Questa"
# ---

info "Make a backup of your Questa makefile, then copy the 'run' makefile from the Bathtub examples source directory to your working directory."
cp Makefile.questa Makefile.questa-BACKUP
cp $BATHTUB_CODEC_SRC/Makefile_run.questa $CODEC_WORKING_DIR/Makefile.questa

info "Run the original 'test' with the new Bathtub testbench in Questa."
echo
make -f Makefile.questa test_with_bathtub || exit

info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in Questa."
echo
make -f Makefile.questa bathtub_test || exit
info "Congratulations!"

# info "Run VCS"
# # ---
#
# info "Make a backup of your VCS makefile, then copy the 'run' makefile from the Bathtub examples source directory to your working directory."
# cp Makefile.vcs Makefile.vcs-BACKUP
# cp $BATHTUB_CODEC_SRC/Makefile_run.vcs $CODEC_WORKING_DIR/Makefile.vcs
#
# info "Run the original 'test' with the new Bathtub testbench in VCS."
# echo
# make -f Makefile.vcs test_with_bathtub || exit
#
# info "Run the complete 'bathtub_test' with the Gherkin feature file and step definitions in VCS."
# echo
# make -f Makefile.vcs bathtub_test || exit
# info "Congratulations!"
