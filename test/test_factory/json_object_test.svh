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
        `EXPECT_EQ_DOUBLE(123.0, jv.getObjectMember("i").getNumber())
        `EXPECT_EQ_INT(JSONValue::JSON_STRING, jv.getObjectMember("s").getType())
        `EXPECT_EQ_STRING("abc", jv.getObjectMember("s").getString())
        `EXPECT_EQ_INT(JSONValue::JSON_ARRAY, jv.getObjectMember("a").getType())
        `EXPECT_EQ_INT(3, jv.getObjectMember("a").getArraySize())
        for (int i=0; i<3; i++) begin
            JSONValue this_val;
            this_val = jv.getObjectMember("a").getArrayElement(i);
            `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, this_val.getType())
            `EXPECT_EQ_DOUBLE(i+1.0, this_val.getNumber())
        end
        `EXPECT_EQ_INT(JSONValue::JSON_OBJECT, jv.getObjectMember("o").getType())
        `EXPECT_EQ_INT(3, jv.getObjectMember("o").getArraySize())
        for (int i=0; i<3; i++) begin
            JSONValue this_val;
            this_val = jv.getObjectMember("o").getObjectMember($sformatf("%0d", i+1));
            `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, this_val.getType())
            `EXPECT_EQ_DOUBLE(i+1.0, this_val.getNumber())
        end

        `REPORT_TEST()
    endtask: test
endclass: json_object_test 

