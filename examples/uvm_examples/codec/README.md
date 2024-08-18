# codec
The reference implementation libraries for UVM 1.0, 1.1, and 1.2 include complete source code for a working verification environment for a simple parallel-to-serial codec.
We are going to apply Bathtub to that codec environment.
The purpose is to illustrate how you can apply Bathtub to any UVM testbench.
## Overview
In general, these are the steps for applying Bathtub to a UVM testbench.
1. Build a working UVM environment.
   * It should follow standard practices and include a top module, DUT, environment (`uvm_env`), and virtual sequencer.
   * You should have the simulators, scripts, and support files required to run the environment.
2. Create a new Bathtub test (`uvm_test`).
   * Instantiate a Bathtub object (`bathtub_pkg::bathtub`) and configure it with your virtual sequencer.
   * Since Bathtub will provide sequences for some of your sequencers, the test should disable any default sequences for run-time phases that might conflict.
3. Write a Gherkin feature file that describes and exercises the behavior of the DUT.
4. Write step definitions (`uvm_sequence`) for every step in the feature file.
5. Run!

This README walks through the above steps for the codec example.
## Build a UVM Environment
Fortunately this has already been done for you.
Download the UVM 1.2 reference implementation class library code ([uvm-1.2.tar.gz](https://accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz)) from Accellera's UVM download page, <https://accellera.org/downloads/standards/uvm>.

Often UVM is installed in a central, shared location protected by restricted permissions.
However, for this codec example, you need your own personal UVM installation with full read and write access permissions.
The UVM 1.2 `README.txt` has instructions for installing the kit.
Follow them to unpack the tarball into a "convenient location," perhaps somewhere under your home directory.
```
Installing the kit
------------------

Installation of UVM requires first unpacking the kit in a convenient
location.

    % mkdir path/to/convenient/location
    % cd path/to/convenient/location
    % gunzip -c path/to/UVM/distribution/tar.gz | tar xvf -
```
It is not necessary to set or override the `UVM_HOME` environment variable; the codec scripts take care of that for you.
It doesn't matter if you typically use a UVM version other than 1.2.
The codec example is self-contained and will compile UVM directly from your personal 1.2 installation.

Alternatively, if you already have UVM 1.2 installed somewhere on your file system, you don't need to download it again. You can just copy the entire directory to your personal convenient location with `cp -r`.

You'll be bouncing around a few different directories, so let's give them pseudo variable names to make this discussion easier.
| Name | Description |
| --- | --- |
| `USER_UVM_HOME` | Path to your personal UVM installation. |
| `CODEC_WORKING_DIR` | Path to your codec example. This is your working directory. `CODEC_WORKING_DIR=$USER_UVM_HOME/examples/integrated/codec` |
| `BATHTUB_VIP_DIR` | Path to your Bathtub installation directory. This should be an actual environment variable. |
| `BATHTUB_CODEC_SRC` | Path to the Bathtub codec example source, i.e., the directory containing this `README.md` file. You will copy files from `$BATHTUB_CODEC_SRC` to `$CODEC_WORKING_DIR`. `BATHTUB_CODEC_SRC=$BATHTUB_VIP_DIR/examples/uvm_examples/codec` |

Change to your working directory (`cd $CODEC_WORKING_DIR`) and try to run the codec example as-is.
The directory contains makefiles for the Big Three simulators: Incisive (`ius`), Questa, and VCS.
If you're unfamiliar with makefiles, you can learn about them at <https://www.gnu.org/software/make/>.
Choose your preferred simulator and try running with the corresponding makefile.
| Simulator | Command |
| --- | --- |
| Incisive | `make -f Makefile.ius test` |
| Questa | `make -f Makefile.questa run` # Note that the target is `run`, not `test` like the others. |
| VCS | `make -f Makefile.vcs test` |

Do whatever you need to do to get your simulation to run and pass on your system.
If you look inside the makefiles, you'll see that they each include a corresponding makefile two directories higher (`include ../../Makefile.xxx`), in `$USER_UVM_HOME/examples`.
You may need to set up your environment, or edit the local makefiles in this directory or the included makefiles two directories up.
(They're your personal makefiles, so edit them as much as you like. You might want to make backup copies first.)

Cadence replaced Incisive with Xcelium, so feel free to make a pair of `Makefile.xcelium` files appropriate for the newer simulator, changing "irun" to "xrun," and use those instead.
That's what we've done.
We run Xcelium like so:
`make -f Makefile.xcelium test`

The simulators produce various log files and other artifacts in your working directory.
The included makefiles all have `clean` targets you can use to remove those files.

| Simulator | Command |
| --- | --- |
| Incisive | `make -f Makefile.ius clean` |
| Questa | `make -f Makefile.questa clean` |
| VCS | `make -f Makefile.vcs clean` |

Once your simulation is running and passing, you're ready to move on.

## Create a New Bathtub Test
You got the codec testbench running as-is.
Now we're going to modify it.

`$CODEC_WORKING_DIR/README.txt` briefly describes the DUT, and `$CODEC_WORKING_DIR/block_diagram.pdf` gives an overview of the testbench.
Here's a UML class diagram of the testbench that focuses on the parts relevant to this Bathtub exercise.

[![](https://mermaid.ink/img/pako:eNqVVU1v3CAQ_SuIXpImrnq2Vj70I1JPUdNjXVkYj70oGBwMbqp0_3sHfyz2LittfbCHeW9mHgzgN8p1BTSlSZLkygorISWPRjRCMUk-I8ZJCbU2QD4xu7euzNVI5ZL1_RfBGsPaXBF8Rg-xZWF1R94mn392u1ZXTkKWBR-3kqSei0YxiDoglbMfEcLP5DtMH8Va6DvGgbCuLLrnZl1hquwB1oCyMaCHFweKg7mQtTPaz-Q8q4X-LCHqBjWceg00xWXZg-jisj0Qle2BuGyviSTJ34y4oS2CwklXQI4i11M5aZYPWGm6w2Zc6Mxd6YSsim7PergZ30j0ZUb7dkXkWing9hqqgR6uIrZMqGt4nZOyqI1ui6fXh28PjxfZh82avU-SsIGQjfYZPjcYUbRwT4M8o2x65tfxtegNj9KWSmivuqoRnYkpOfYv8GNFIhvlZGttOlyZYQ6qjBiWiBFCua1WM4qWsHoNm4vwYV02rON5WY-1rLebslPSEYokDemWJq0n37_M7KU7OkKqoGZOWqzcfYiu1BK8ERyC5u3jWTjaqFsij4fOO0qp-XNQH6QcWWt1ux0phapIlu3I09fvJMnGKPObZKH9_5_DR1mz5Ag30XgQYjfR9jLZ-iP33UbCz5xuxu9uUMVtTn_Fok6W6EDvaQsGT3iFP6JRVk7tHlrIaYrm3Iic5spTmbP6xx_FaWqNg3tqtGv2NK2Z7HHkuopZmH9Ms_fwD356Nbk?type=png)](https://mermaid.live/edit#pako:eNqVVU1v3CAQ_SuIXpImrnq2Vj70I1JPUdNjXVkYj70oGBwMbqp0_3sHfyz2LittfbCHeW9mHgzgN8p1BTSlSZLkygorISWPRjRCMUk-I8ZJCbU2QD4xu7euzNVI5ZL1_RfBGsPaXBF8Rg-xZWF1R94mn392u1ZXTkKWBR-3kqSei0YxiDoglbMfEcLP5DtMH8Va6DvGgbCuLLrnZl1hquwB1oCyMaCHFweKg7mQtTPaz-Q8q4X-LCHqBjWceg00xWXZg-jisj0Qle2BuGyviSTJ34y4oS2CwklXQI4i11M5aZYPWGm6w2Zc6Mxd6YSsim7PergZ30j0ZUb7dkXkWing9hqqgR6uIrZMqGt4nZOyqI1ui6fXh28PjxfZh82avU-SsIGQjfYZPjcYUbRwT4M8o2x65tfxtegNj9KWSmivuqoRnYkpOfYv8GNFIhvlZGttOlyZYQ6qjBiWiBFCua1WM4qWsHoNm4vwYV02rON5WY-1rLebslPSEYokDemWJq0n37_M7KU7OkKqoGZOWqzcfYiu1BK8ERyC5u3jWTjaqFsij4fOO0qp-XNQH6QcWWt1ux0phapIlu3I09fvJMnGKPObZKH9_5_DR1mz5Ag30XgQYjfR9jLZ-iP33UbCz5xuxu9uUMVtTn_Fok6W6EDvaQsGT3iFP6JRVk7tHlrIaYrm3Iic5spTmbP6xx_FaWqNg3tqtGv2NK2Z7HHkuopZmH9Ms_fwD356Nbk)

The testbench has a `uvm_test` class called `test` that really doesn't do anything.
We're going to extend it into a new class called `bathtub_test`.
The existing `test` class is defined in file `$CODEC_WORKING_DIR/test.sv`.
That file `` `include``s a file called `$CODEC_WORKING_DIR/testlib.svh`, which is a library of additional tests.
We'll add our new test to `testlib.svh`.
You can find our new Bathtub test in `$BATHTUB_CODEC_SRC/bathtub_test.svh`.
You can also find in `$BATHTUB_CODEC_SRC` a modified version of `testlib.svh` which`` `include``s our Bathtub test.
All you need to do is copy `bathtub_test.svh` and a `testlib.svh` from `$BATHTUB_CODEC_SRC` into `$CODEC_WORKING_DIR`.
`bathtub_test.svh` is new to `$CODEC_WORKING_DIR`, but `testlib.svh` will overwrite the existing version.
```
# Copy two files from the Bathtub examples directory into your working directory
cp $BATHTUB_CODEC_SRC/bathtub_test.svh $BATHTUB_CODEC_SRC/testlib.svh $CODEC_WORKING_DIR
```
### Add a Virtual Sequencer
The original codec testbench instantiates three "concrete" sequencers:
1. `test.env.tx_src : vip_sequencer` -- Provides `vip_tr` sequence items containing data bytes that the testbench's main routine writes into the DUT's `TxFIFO` to be transmitted.
2. `test.env.vip.sqr : vip_sequencer` -- Provides `vip_tr` sequence items containing data bytes that the testbench's VIP driver transmits into the DUT's serial `rx` input.
3. `test.env.apb.sqr : apb_sequencer` -- Receives register accesses from the register model in the form of `apb_rw` sequence items and executes them on the DUT's APB interface.

Unfortunately the testbench does not contain a virtual sequencer to tie them all together.
This omission simplifies the testbench, but it precludes any virtual sequences that might combine the three concrete sequencers in interesting ways, such as looping back transmitted data.
We want Bathtub to have the benefit of a virtual sequencer, so we enhance the codec testbench by adding one.

Copy the virtual sequencer file from the Bathtub examples source directory to your working directory.
```
cp $BATHTUB_CODEC_SRC/tb_virtual_sequencer.svh $CODEC_WORKING_DIR
```
The Bathtub test already instantiates the virtual sequencer and connects it to the concrete sequencers.

This updated UVM diagram shows the testbench with the Bathtub test and virtual sequencer added.

[![](https://mermaid.ink/img/pako:eNqVVktvnDAQ_iuWc9k0ocoZrTi0TaReWjU9lgoZMLtWjE2MTRKl-e8d8zJmTR57WTPfN-_xwDMuZElxjKMoSoVmmtMYfQVRga7FkYiCluiB6SP6QvRRmzwVPbHgpG2_MXJQpE4Fgl8vQTrPtGzQ8yCzv_2-lqXhNEmcrNAcxZYLh6xjlUNKo68Agr9B9jL8CVLTtiEFRaTJs-busPQweLYAOVChQ0BL7w2FXNSG1UZJm8mpVU3bE4P5UIkshEFOHVPaEL726XGo6NZSRQ_ZdtqTz2Dq-dSahaqHLFUuCikqdjCK7uYIoeKmq13EWU5aer7QUUb06e6aIyAjvT-fbwTcsSYcrAWCfbJAuE_WM4qif0nv1pV9KKRD5qque7fs2EB3mJCaokoqn5TiH_RhLl_PxgFbn6Io2HKo0MYYtPqJU99IxTiPz66qas7q1N6cY9BcUGVlds4zSB7yHeXIOdlKeqpM7A9f0LYE_jjdwIcTLATK31DwpsEui8esVcUHlfrneyjVakXZqVleCVhBG_voIjeMl8Oobw7_dK0ELfR7qIq29F3EmjDxHl5jOM8qJevs9vHm-83Pt67pWALbyHltAhvOJ_grjZsob7RqSZs8wXlxteVwiywxRvMldvyQk76tga3i9bVU3TgFpWLdchNfQJC1FCMKJ6blElabsLdfXfVO3VqsJq323A5Geyhg1JmbWhNMeeqJDJBKWhHDNXhuPq92hfee8QN2SuPQWBY8edFNmvMusoKcy-LORf_axgLT-z3KmShRkuzR7fUvFCW9lnpAiWv6x21YLa0mG-4l1I9_6CXkv0d8eeDd7IXwJ8Xe89kOojhP8d-Q1qpEL_gS11TBvS7hk6sPK8X6SGua4hiOYyPs2rVUYrT8_SQKHGtl6CVW0hyOOK4Ib-HJNCXRdPwIG6Uv_wH0hTiN?type=png)](https://mermaid.live/edit#pako:eNqVVktvnDAQ_iuWc9k0ocoZrTi0TaReWjU9lgoZMLtWjE2MTRKl-e8d8zJmTR57WTPfN-_xwDMuZElxjKMoSoVmmtMYfQVRga7FkYiCluiB6SP6QvRRmzwVPbHgpG2_MXJQpE4Fgl8vQTrPtGzQ8yCzv_2-lqXhNEmcrNAcxZYLh6xjlUNKo68Agr9B9jL8CVLTtiEFRaTJs-busPQweLYAOVChQ0BL7w2FXNSG1UZJm8mpVU3bE4P5UIkshEFOHVPaEL726XGo6NZSRQ_ZdtqTz2Dq-dSahaqHLFUuCikqdjCK7uYIoeKmq13EWU5aer7QUUb06e6aIyAjvT-fbwTcsSYcrAWCfbJAuE_WM4qif0nv1pV9KKRD5qque7fs2EB3mJCaokoqn5TiH_RhLl_PxgFbn6Io2HKo0MYYtPqJU99IxTiPz66qas7q1N6cY9BcUGVlds4zSB7yHeXIOdlKeqpM7A9f0LYE_jjdwIcTLATK31DwpsEui8esVcUHlfrneyjVakXZqVleCVhBG_voIjeMl8Oobw7_dK0ELfR7qIq29F3EmjDxHl5jOM8qJevs9vHm-83Pt67pWALbyHltAhvOJ_grjZsob7RqSZs8wXlxteVwiywxRvMldvyQk76tga3i9bVU3TgFpWLdchNfQJC1FCMKJ6blElabsLdfXfVO3VqsJq323A5Geyhg1JmbWhNMeeqJDJBKWhHDNXhuPq92hfee8QN2SuPQWBY8edFNmvMusoKcy-LORf_axgLT-z3KmShRkuzR7fUvFCW9lnpAiWv6x21YLa0mG-4l1I9_6CXkv0d8eeDd7IXwJ8Xe89kOojhP8d-Q1qpEL_gS11TBvS7hk6sPK8X6SGua4hiOYyPs2rVUYrT8_SQKHGtl6CVW0hyOOK4Ib-HJNCXRdPwIG6Uv_wH0hTiN)

This object diagram shows how the `tb_env` component instantiates all the concrete sequencers as children or grandchildren, and the virtual sequencer simply references them all.
The register model has a reference to the APB sequencer and provides a useful register-based interface to it, so the virtual sequencer contains a reference to the register model instead of the APB sequencer directly.

[![](https://mermaid.ink/img/pako:eNqdlM1ugzAMx18lyrm8ANftvkOlXcaEQjCQCZIucapNVd99pgmUUNpK44Ac5_c3_hInLk0NPOdZlhUaFfaQs7fqCySyVyVaKwZmGoYdsHdl0Yue7eHbg5Zg2YvRmkBltCv0JYDshXNRV2hGz8XDKoEd-qpEcPhR8OWR5cltwT-XQqxK0EeS0JvIcFwxR3Uo3ZRU6b4t4fQmPLlZqSy0Ze3HbMgaqAk9CaJzhYpDVYoW9AiTTdzs2SDnD85pJN6HyeNP6awkYTCelDDeTXmRHemtvKhvxzC-JL0bX2jxjfsSLcRLRpdlcSKkk0ajUOMmBDBeEDI3K6FSJjb-ATGX9oRZN3M7tdvKkyQsNGBHv3usuPPB_8nDsiy1QX2t_I4kbce13bH3y-mm6FTwBrguYWPuW9szxec7PoAdhKrp33IaQ9BOdzBAwXMya2iE72lLC30mVHg0-18teY7Ww45b49uO543oHZ38oRYI8a8Svec_Gzqrbw?type=png)](https://mermaid.live/edit#pako:eNqdlM1ugzAMx18lyrm8ANftvkOlXcaEQjCQCZIucapNVd99pgmUUNpK44Ac5_c3_hInLk0NPOdZlhUaFfaQs7fqCySyVyVaKwZmGoYdsHdl0Yue7eHbg5Zg2YvRmkBltCv0JYDshXNRV2hGz8XDKoEd-qpEcPhR8OWR5cltwT-XQqxK0EeS0JvIcFwxR3Uo3ZRU6b4t4fQmPLlZqSy0Ze3HbMgaqAk9CaJzhYpDVYoW9AiTTdzs2SDnD85pJN6HyeNP6awkYTCelDDeTXmRHemtvKhvxzC-JL0bX2jxjfsSLcRLRpdlcSKkk0ajUOMmBDBeEDI3K6FSJjb-ATGX9oRZN3M7tdvKkyQsNGBHv3usuPPB_8nDsiy1QX2t_I4kbce13bH3y-mm6FTwBrguYWPuW9szxec7PoAdhKrp33IaQ9BOdzBAwXMya2iE72lLC30mVHg0-18teY7Ww45b49uO543oHZ38oRYI8a8Svec_Gzqrbw)
