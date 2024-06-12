def test_all(tmp_path, svunit, simulator):
    """Run all unit tests with runSVUnit."""
    assert simulator.append_arg('$BATHTUB_VIP_DIR/vip-spec.sv').run(tmp_path).passed()
    assert svunit.sim(simulator).uvm().out(tmp_path).run().passed()
