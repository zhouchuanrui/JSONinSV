//
//File: json_number_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/27 21:50:10
//Description: number test
//Revisions: 
//2021/2/27 21:50:23: created
//

class json_number_test extends TestPrototype;
    `__register(json_number_test)

    function void testNumber (
        real exp, string json
    );
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads(json));
        `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, jv.getType());
        `EXPECT_EQ_STRING("JSON_NUMBER", jv.getTypeString());
        `EXPECT_EQ_DOUBLE(exp, jv.getNumber());
    endfunction: testNumber

    task test ();
        JSONValue jv;
        $display("Start JSON literal test..");
        testNumber(0.0, "0");
        testNumber(0.0, "-0");
        testNumber(0.0, "-0.0");
        testNumber(1.0, "1");
        testNumber(-1.0, "-1");
        testNumber(0.0, "-1");
        `REPORT_TEST()
    endtask: test

endclass: json_number_test

