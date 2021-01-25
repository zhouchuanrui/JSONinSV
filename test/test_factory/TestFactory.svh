//
//File: TestFactory.svh
//Device: 
//Created:  2017-4-18 23:06:21
//Description: test factory
//Revisions: 
//2017-4-18 23:06:32: created
//

`ifndef __TEST_FACTORY_SVH__
`define __TEST_FACTORY_SVH__

virtual class TestPrototype;
    pure virtual task test ();
endclass: TestPrototype

class TestFactory;
    static local TestPrototype tests[string];

    static function void register (TestPrototype obj, string test_name);
        assert(obj != null) 
        else begin
            $display("Can't register null object in factory!!");
            return;
        end
        if (tests.exists(test_name)) begin
            $display("Override obj registered with '%s'!!", test_name);
        end
        tests[test_name] = obj;
    endfunction: register

    static task run_test (string test_name);
        if (!tests.exists(test_name)) begin
            $display("Can't find %s in factory!!", test_name);
            listTests();
            return;
        end
        tests[test_name].test();
    endtask: run_test

    static function void listTests ();
        string tn;
        if(tests.first(tn)) begin
            $display("Tests available: ");
            do begin
                $display("   %s", tn);
            end while (tests.next(tn));
        end
        else begin
            $display("No test in factory!!");
        end
    endfunction: listTests
endclass

`define __register(T) \
static local T reg_obj = get(); \
static local function T get(); \
    if (reg_obj == null) begin \
        reg_obj = new();  \
        TestFactory::register(reg_obj, `"T`"); \
    end \
    return reg_obj; \
endfunction

task factory_run_test ();
    string tn;

    if($value$plusargs("TEST=%s", tn)) begin
        TestFactory::run_test(tn);
    end
    else begin
        $display("Please offer a +TEST=<test_name> in simulation arguments");
        TestFactory::listTests();
    end
endtask: factory_run_test

`endif

