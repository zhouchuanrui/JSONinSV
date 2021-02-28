//
//File: json_object_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/28 22:12:14
//Description: object test for json
//Revisions: 
//2021/2/28 22:12:24: created
//

class json_object_test extends TestPrototype;
    `__register(json_object_test)

    task test ();
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads(" {   } "))
        `EXPECT_EQ_INT(JSONValue::JSON_OBJECT, jv.getType())
        `EXPECT_EQ_STRING("JSON_OBJECT", jv.getTypeString())
        `EXPECT_EQ_INT(0, jv.getObjectSize())

        `REPORT_TEST()
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads(
            {
            " { ",
            "\"n\" : null , ",
            "\"f\" : false , ",
            "\"t\" : true , ", 
            "\"i\" : 123 , ",
            "\"s\" : \"abc\", ",
            "\"a\" : [ 1, 2, 3 ],",
            "\"o\" : { \"1\" : 1, \"2\" : 2, \"3\" : 3 }",
            " } "
        }
        ))
        `EXPECT_EQ_INT(7, jv.getObjectSize())
        `EXPECT_EQ_INT(JSONValue::JSON_NULL, jv.getObjectMember("n").getType())
        `EXPECT_EQ_INT(JSONValue::JSON_FALSE, jv.getObjectMember("f").getType())
        `EXPECT_EQ_INT(JSONValue::JSON_TRUE, jv.getObjectMember("t").getType())
        `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, jv.getObjectMember("i").getType())
    endtask: test
endclass: json_object_test 

