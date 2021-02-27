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
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("null"))
        `EXPECT_EQ_INT(JSONValue::JSON_NULL, jv.getType())
        `EXPECT_EQ_STRING("JSON_NULL", jv.getTypeString())

        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("NULL"))
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("Null"))

        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("true"))
        `EXPECT_EQ_INT(JSONValue::JSON_TRUE, jv.getType())
        `EXPECT_EQ_STRING("JSON_TRUE", jv.getTypeString())
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("TRUE"))
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("True"))

        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("false"))
        `EXPECT_EQ_INT(JSONValue::JSON_FALSE, jv.getType())
        `EXPECT_EQ_STRING("JSON_FALSE", jv.getTypeString())
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("FALSE"))
        `EXPECT_NEQ_INT(json_pkg::PARSE_OK, jv.loads("False"))

        TestStat::report();
    endtask

endclass: json_literal_test

