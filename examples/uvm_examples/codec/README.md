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

[![](https://mermaid.ink/img/pako:eNqVVUtvnDAQ_iuWe0maUPWMVhz6iNRT1fRYKmTM7C6KsYkfJFW6_71jHmtYjLTlAOP5vpn57LHNG-WqAprSJElyaWsrICWf0cXJS22PylnyidmjdWUuewoXzJgvNTto1uSS4NN7iC0Lq1ryNvj8s9s1qnICsiz4uBUk9Vw0iq7eB6Ry9iNC-Bl8p-EjWQOmZRwIa8uifTrMKwyVPcAOIG0MMPDsQHLQG1lbrfxM1lktmFVC1A2yu_RqOBTbsru6jcv2QFS2B-KyvSaSJH8z4rqmCAoHXQE5i5xP5aJZPmCm6Q6bsdGZu9LVoiraIzNw07-R6Mv09u2MyJWUwO01VA0GriI2rJbX8FonRLHXqikeXx--PXzfZJ8Wa_Y-ScIGQjbaK3xsMKJo4Z4GsaIseubX8bUwmkdpUyW0Z11ViI7ElJz7F_ixIpGNcrG1Fh2udDcGVbrupogeQrmNkiOKVm3VHNab8GleNqzjuqzHGmbsouyQtIciSUO6qUnzyZvnkT11R0VIFeyZExYrtx-iKzUFLwSHoHH7eBaOFuqmyPOh845SKP4U1AcpZ9Zc3W5HylpWJMt25PHrD5JkfZR-IVlo___n8FFWTznCTdQfhNhNtLxMlv7IfbeQ8Cuni_G7G1Rxm9PfsaiLJTrRe9qAxhNe4Q-ol5VTe4QGcpqiOTYip7n0VOas-vlHcppa7eCeauUOR5rumTA4cm3FLIw_ptF7-gfhYjMF?type=png)](https://mermaid.live/edit#pako:eNqVVUtvnDAQ_iuWe0maUPWMVhz6iNRT1fRYKmTM7C6KsYkfJFW6_71jHmtYjLTlAOP5vpn57LHNG-WqAprSJElyaWsrICWf0cXJS22PylnyidmjdWUuewoXzJgvNTto1uSS4NN7iC0Lq1ryNvj8s9s1qnICsiz4uBUk9Vw0iq7eB6Ry9iNC-Bl8p-EjWQOmZRwIa8uifTrMKwyVPcAOIG0MMPDsQHLQG1lbrfxM1lktmFVC1A2yu_RqOBTbsru6jcv2QFS2B-KyvSaSJH8z4rqmCAoHXQE5i5xP5aJZPmCm6Q6bsdGZu9LVoiraIzNw07-R6Mv09u2MyJWUwO01VA0GriI2rJbX8FonRLHXqikeXx--PXzfZJ8Wa_Y-ScIGQjbaK3xsMKJo4Z4GsaIseubX8bUwmkdpUyW0Z11ViI7ElJz7F_ixIpGNcrG1Fh2udDcGVbrupogeQrmNkiOKVm3VHNab8GleNqzjuqzHGmbsouyQtIciSUO6qUnzyZvnkT11R0VIFeyZExYrtx-iKzUFLwSHoHH7eBaOFuqmyPOh845SKP4U1AcpZ9Zc3W5HylpWJMt25PHrD5JkfZR-IVlo___n8FFWTznCTdQfhNhNtLxMlv7IfbeQ8Cuni_G7G1Rxm9PfsaiLJTrRe9qAxhNe4Q-ol5VTe4QGcpqiOTYip7n0VOas-vlHcppa7eCeauUOR5rumTA4cm3FLIw_ptF7-gfhYjMF)

The example has a `uvm_test` class called `test` that really doesn't do anything.
We're going to extend it into a new class called `bathtub_test`.
The existing `test` class is defined in file `$CODEC_WORKING_DIR/test.sv`.
That file `` `include``s a file called `$CODEC_WORKING_DIR/testlib.svh`, which is a library which contains another test class.
You can find our new Bathtub test in `$BATHTUB_CODEC_SRC/bathtub_test.svh`.
You can also find a modified version of `testlib.svh` in `$BATHTUB_CODEC_SRC`.
The modified version `` `include``s our `bathtub_test.svh`.
All you need to do is copy `bathtub_test.svh` and a `testlib.svh` from `$BATHTUB_CODEC_SRC` into `$CODEC_WORKING_DIR`.
`bathtub_test.svh` is new to `$CODEC_WORKING_DIR`, but `testlib.svh` will overwrite the existing version.
```
# Copy two files from the Bathtub examples directory into your working directory
cp $BATHTUB_CODEC_SRC/bathtub_test.svh $BATHTUB_CODEC_SRC/testlib.svh $CODEC_WORKING_DIR
```

[![](https://mermaid.ink/img/pako:eNqVVktvnDAQ_iuWe0maUOWMVnvoI1IvrZoeS4UMDLsoxibGJonS_PeOeRmzJo-9rJnvm_d44InmsgAa0yiKEqErzSEmX1CUk_tKH8lnpo_aZIno8Zyztv1asYNidSII_noJ0VmqZUOeBpn97Xa1LAyH_d7Jcs1JbLl4SLuqdEhh9BVC-DfInoc_wWpoG5YDYU2WNreHpYfBswXYAYQOAS3cGRA5qA2rjZI2k1OrGtoTg9lQiTSEYU5dpbRhfO3T44Do1lIFh3Q77clnMPVsas1C1UOWKhe5FGV1MArO5gix4qarXcRpxlo4X-goI_p0z5ojIiO9P59vBNxVTThYCwT7ZIFwn6xnEkX_9r1bV_ahkA6Zq7ru3bJjA91hQmogpVQ-KaE_4H4uX8-mAVsfoyjYcqzQxhi0-pGDb6SsOI8_XJXlnNWpvTnHoLmgysrsnGeQPOQ7yolzspX0VJnYH76gbYn8cbqRjydcCMBfUfCmwS6Lh7RV-TuV-uc7LNVqRdmpWV4JXEEb--giMxUvhlHfHP7pWgnI9VuoClp4E7FmlXgLrzGcp6WSdXrzcP39-udr13QsgW3kvDaRjecT_IXGTZRXWrWkTZ7wvLjacrhFlhiT-RI7fshJ39bAVvH6WqhunIJCVd1yE19gkLUUI4qnSsslrDZhb7-66p26tVjNWu25HYz2UMCoMze1Jpjy1BMZIBVQMsM1em4-rXaF957xA3ZK49BYFj550U2a8y6ygozL_NZF_9LGQtO7HckqUZD9fkduvv0i0b7XUvdk75r-fhtWS6vJhnsJ9eMfegn57xFfHng3eyH8Saj3_OEMozhP6N-Q1qpEz_SS1qDwXhf4pdWHlVB9hBoSGuNxbIRdu5bKjJa_H0VOY60MXFIlzeFI45LxFp9MUzAN40fYKH3-D4cWNVc?type=png)](https://mermaid.live/edit#pako:eNqVVktvnDAQ_iuWe0maUOWMVnvoI1IvrZoeS4UMDLsoxibGJonS_PeOeRmzJo-9rJnvm_d44InmsgAa0yiKEqErzSEmX1CUk_tKH8lnpo_aZIno8Zyztv1asYNidSII_noJ0VmqZUOeBpn97Xa1LAyH_d7Jcs1JbLl4SLuqdEhh9BVC-DfInoc_wWpoG5YDYU2WNreHpYfBswXYAYQOAS3cGRA5qA2rjZI2k1OrGtoTg9lQiTSEYU5dpbRhfO3T44Do1lIFh3Q77clnMPVsas1C1UOWKhe5FGV1MArO5gix4qarXcRpxlo4X-goI_p0z5ojIiO9P59vBNxVTThYCwT7ZIFwn6xnEkX_9r1bV_ahkA6Zq7ru3bJjA91hQmogpVQ-KaE_4H4uX8-mAVsfoyjYcqzQxhi0-pGDb6SsOI8_XJXlnNWpvTnHoLmgysrsnGeQPOQ7yolzspX0VJnYH76gbYn8cbqRjydcCMBfUfCmwS6Lh7RV-TuV-uc7LNVqRdmpWV4JXEEb--giMxUvhlHfHP7pWgnI9VuoClp4E7FmlXgLrzGcp6WSdXrzcP39-udr13QsgW3kvDaRjecT_IXGTZRXWrWkTZ7wvLjacrhFlhiT-RI7fshJ39bAVvH6WqhunIJCVd1yE19gkLUUI4qnSsslrDZhb7-66p26tVjNWu25HYz2UMCoMze1Jpjy1BMZIBVQMsM1em4-rXaF957xA3ZK49BYFj550U2a8y6ygozL_NZF_9LGQtO7HckqUZD9fkduvv0i0b7XUvdk75r-fhtWS6vJhnsJ9eMfegn57xFfHng3eyH8Saj3_OEMozhP6N-Q1qpEz_SS1qDwXhf4pdWHlVB9hBoSGuNxbIRdu5bKjJa_H0VOY60MXFIlzeFI45LxFp9MUzAN40fYKH3-D4cWNVc)

