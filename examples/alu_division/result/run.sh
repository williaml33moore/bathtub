cd /home/runner
export PATH=/usr/bin:/bin:/tool/pandora64/bin:/xcelium20.09/tools/bin:/xcelium20.09/bin:/xcelium20.09/tools/systemc/gcc/bin
export IFV_HOME=/xcelium20.09
export LDV_TOOLS=/xcelium20.09/tools
export SPMN_HOME=/xcelium20.09
export TOP_INSTALL_DIR=/xcelium20.09
export LM_LICENSE_FILE=5280@10.116.0.5
export UVM_HOME=/xcelium20.09/tools//methodology/UVM/CDNS-1.2/sv
export IUS_HOME=/xcelium20.09
export SOCV_KIT_HOME=/xcelium20.09
export SPECMAN_HOME=/xcelium20.09/specman
export EMGR_HOME=/xcelium20.09
export NCSIM_VERSION=20.09
export HOME=/home/runner
export LDV_HOME=/xcelium20.09
xrun -Q -unbuffered '-f' 'files.f' '+define+EDAPG' '-timescale' '1ns/1ns' '-sysv' '-access' '+rw' '+UVM_TESTNAME=bathtub_test' '+UVM_VERBOSITY=UVM_HIGH' -uvmnocdnsextra -uvmhome $UVM_HOME $UVM_HOME/src/uvm_macros.svh design.sv testbench.sv  ; echo 'Creating result.zip...' && zip -r /tmp/tmp_zip_file_123play.zip . && mv /tmp/tmp_zip_file_123play.zip result.zip