import subprocess
import pytest

classes_under_test = [
    "bathtub_pkg/bathtub_pkg.svh",
    "bathtub_pkg/bathtub.svh",
    "bathtub_pkg/bathtub_utils.svh",
    "bathtub_pkg/feature_sequence_interface.svh",
    "bathtub_pkg/feature_sequence.svh",
    "bathtub_pkg/gherkin_doc_bundle.svh",
    "bathtub_pkg/line_value.svh",
    "bathtub_pkg/pool_provider_interface.svh",
    "bathtub_pkg/pool_provider.svh",
    "bathtub_pkg/scenario_sequence_interface.svh",
    "bathtub_pkg/scenario_sequence.svh",
    "bathtub_pkg/step_attributes_interface.svh",
    "bathtub_pkg/step_definition_interface.svh",
    "bathtub_pkg/step_nature.svh",
    "bathtub_pkg/step_nurture.svh",
    "bathtub_pkg/step_parameter_arg.svh",
    "bathtub_pkg/step_parameters.svh",
    "bathtub_pkg/step_static_attributes_interface.svh",
    "bathtub_pkg/gherkin_document_printer/gherkin_document_printer.svh",
    "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh",
    "bathtub_pkg/gherkin_parser/gherkin_parser.svh",
]

@pytest.fixture(params=classes_under_test)
def class_under_test(request):
    return request.param

@pytest.fixture(params=['xrun -uvmnocdnsextra', 'qrun'])
def simulator(request):
    return request.param

def test_class_dependencies(tmp_path, simulator, class_under_test):
    """Test that each class fully specifies all its dependencies"""
    # Create a minimal top level that just includes the class file.
    # Simulate it with only required packages and include directories.
    # Class file should include everything it needs and compile successfully.
    f = tmp_path / 'testbench.sv'
    content = "\n".join(['program test();',
                         '`include "' + class_under_test + '"',
                        'endprogram : test'
                        ])
    f.write_text(content, encoding="utf-8")
    run_cmd = simulator + " " + """\
-uvm \
-uvmhome $UVM_HOME \
$BATHTUB_VIP_DIR/src/gherkin_pkg/gherkin_pkg.sv \
-incdir $BATHTUB_VIP_DIR/src \
testbench.sv \
#
"""
    assert subprocess.run(run_cmd, shell=True, cwd=tmp_path).returncode == 0

def test_macro_dependencies(tmp_path, simulator):
    """Test that bathtub_macros dependencies are satisfied by bathtub_pkg"""
    # Bathtub_macros doesn't include or import any depencies on its own.
    # Ensure that compiling bathtub_pkg satisfies bathtub_macros' requirements.
    class_under_test = 'bathtub_macros.sv'
    f = tmp_path / 'testbench.sv'
    content = "\n".join(['program test();',
                         '`include "' + class_under_test + '"',
                        'endprogram : test'
                        ])
    f.write_text(content, encoding="utf-8")
    run_cmd = simulator + " " + """\
-uvm \
-uvmhome $UVM_HOME \
$BATHTUB_VIP_DIR/src/gherkin_pkg/gherkin_pkg.sv \
$BATHTUB_VIP_DIR/src/bathtub_pkg/bathtub_pkg.sv \
-incdir $BATHTUB_VIP_DIR/src \
testbench.sv \
#
"""
    assert subprocess.run(run_cmd, shell=True, cwd=tmp_path).returncode == 0

def test_macro_command_line_dependencies(tmp_path, simulator):
    """Test that bathtub_macros can be compiled from the command line"""
    # The file is called "bathtub_macros.sv," not "bathtub_macros.svh," so ensure it can be compiled from the command line. 
    f = tmp_path / 'testbench.sv'
    content = "\n".join(['program test();',
                         '; // Empty',
                        'endprogram : test'
                        ])
    f.write_text(content, encoding="utf-8")
    run_cmd = simulator + " " + """\
-uvm \
-uvmhome $UVM_HOME \
$BATHTUB_VIP_DIR/src/gherkin_pkg/gherkin_pkg.sv \
$BATHTUB_VIP_DIR/src/bathtub_pkg/bathtub_pkg.sv \
$BATHTUB_VIP_DIR/src/bathtub_macros.sv \
-incdir $BATHTUB_VIP_DIR/src \
testbench.sv \
#
"""
    assert subprocess.run(run_cmd, shell=True, cwd=tmp_path).returncode == 0
