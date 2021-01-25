//
//File: top.sv
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:48:29
//Description: top
// test top module
// run testcase from tests in test_factory
//Revisions: 
//2021/1/26 7:48:35: created
//

module top ();

    initial
    begin
        test_pkg::factory_run_test();
        #1;
        $finish(0);
    end

endmodule: top

