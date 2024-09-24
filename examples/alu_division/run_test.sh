#!/bin/sh


xrun $BATHTUB_VIP_DIR/vip-spec.sv $BATHTUB_VIP_DIR/vip_setup.sv &&
cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature . &&
xrun \
-uvm \
-uvmhome $XCELIUM_HOME/tools.lnx86/methodology/UVM/CDNS-1.2 \
-f bathtub_vip.f \
-incdir $BATHTUB_VIP_DIR/examples/alu_division/result/ \
$BATHTUB_VIP_DIR/examples/alu_division/result/design.sv \
$BATHTUB_VIP_DIR/examples/alu_division/result/testbench.sv \
+UVM_TESTNAME=bathtub_test \
+UVM_VERBOSITY=UVM_HIGH \
#

status=$?
if [[ $status == 0 ]]
then
    echo -e "\033[32mPASS\033[0m"
else
    echo -e "\033[31mFAIL\033[0m"
fi
exit $status
