To run the setup script:

```
cd ~/local/postoffice/svunit-master
source Setup.csh
```

To add a new unit test template for a new class:

```
cd bathtub_pkg_test_suite
create_unit_test.pl -p 'bathtub_pkg::*' -class_name <class_name>
```

To run all unit tests in this directory:

```
cd bathtub_pkg_test_suite
runSVUnit -U
```
