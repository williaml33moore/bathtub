import subprocess
import pytest

classes_under_test = [
    "bathtub_pkg.svh",
    "bathtub.svh",
    "bathtub_utils.svh",
    "feature_sequence_interface.svh",
    "feature_sequence.svh",
    "gherkin_doc_bundle.svh",
    "line_value.svh",
    "pool_provider_interface.svh",
    "pool_provider.svh",
    "scenario_sequence_interface.svh",
    "scenario_sequence.svh",
    "step_attributes_interface.svh",
    "step_definition_interface.svh",
    "step_nature.svh",
    "step_nurture.svh",
    "step_parameter_arg.svh",
    "step_parameters.svh",
    "step_static_attributes_interface.svh",
    "gherkin_document_printer.svh",
    "gherkin_document_runner.svh",
    "gherkin_parser.svh",
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
-incdir $BATHTUB_VIP_DIR/src/gherkin_pkg \
-incdir $BATHTUB_VIP_DIR/src/bathtub_pkg \
-incdir $BATHTUB_VIP_DIR/src/bathtub_pkg/gherkin_document_printer \
-incdir $BATHTUB_VIP_DIR/src/bathtub_pkg/gherkin_document_runner \
-incdir $BATHTUB_VIP_DIR/src/bathtub_pkg/gherkin_parser \
testbench.sv \
#
"""
    assert subprocess.run(run_cmd, shell=True, cwd=tmp_path).returncode == 0
