# Test Factory

[Introduction on github.io](https://zhouchuanrui.github.io/2017/03/28/note_asic/run_test_demo/)

A UVM `run_test` like tests factory is implemented in `TestFactory.svh`. 

Add `+TEST=<test_name>` to runtime arguments to run certain test, you will get all available test when you input no `+TEST=<test_name>` arguments or wrong test name.
