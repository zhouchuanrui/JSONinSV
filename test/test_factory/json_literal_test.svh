//
//File: json_literal_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/20 20:54:27
//Description: literal test for json
//Revisions: 
//2021/2/20 20:54:44: created
//

class json_literal_test extends TestPrototype;
    `__register(json_literal_test)

    task test();
        JSONValue jv;
        $display("Start JSON literal test..");
        jv = new();
        //assert(json_pkg::PARSE_OK != jv.loads("null"));
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("null"))
        `EXPECT_EQ_INT(JSONValue::JSON_NULL, jv.getType())
        `EXPECT_EQ_STRING("JSON_NULL", jv.getTypeString())

        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("NULL"))
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("Null"))

        TestStat::report();
    endtask

endclass: json_literal_test

