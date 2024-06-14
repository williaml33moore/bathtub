`include "svunit_defines.svh"

module hello_world_vseq_unit_test;
  import svunit_pkg::svunit_testcase;

  typedef class hello_world_vseq;
  `include "step_definitions.svh"

  string name = "hello_world_vseq_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  hello_world_vseq my_hello_world_vseq;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_hello_world_vseq = new(/* New arguments if needed */);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    my_hello_world_vseq = hello_world_vseq::type_id::create("my_hello_world_vseq");
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

    `SVTEST(Hello_world)
      my_hello_world_vseq.body();
      `FAIL_UNLESS(1'b1)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
