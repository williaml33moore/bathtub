#!/bin/sh


qrun $BATHTUB_VIP_DIR/vip-spec.sv &&
cp $BATHTUB_VIP_DIR/examples/alu_division/result/alu_division.feature .
qrun \
-uvm \
-uvmhome $UVM_HOME \
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
