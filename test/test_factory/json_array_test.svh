//
//File: json_array_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/28 22:11:59
//Description: array test for json
//Revisions: 
//2021/2/28 22:12:07: created
//

class json_array_test extends TestPrototype;
    `__register(json_array_test)

    task test ();
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("[]"))
        `EXPECT_EQ_INT(JSONValue::JSON_ARRAY, jv.getType())
        `EXPECT_EQ_STRING("JSON_ARRAY", jv.getTypeString())
        `EXPECT_EQ_INT(0, jv.getArraySize())
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("[ null , false , true , 123 , \"abc\" ]"));
        `EXPECT_EQ_STRING("JSON_ARRAY", jv.getTypeString())
        `EXPECT_EQ_INT(5, jv.getArraySize())
        `EXPECT_EQ_INT(JSONValue::JSON_NULL, jv.getArrayElement(0).getType())
        `EXPECT_EQ_INT(JSONValue::JSON_FALSE, jv.getArrayElement(1).getType())
        `EXPECT_EQ_INT(JSONValue::JSON_TRUE, jv.getArrayElement(2).getType())
        `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, jv.getArrayElement(3).getType())
        `EXPECT_EQ_INT(JSONValue::JSON_STRING, jv.getArrayElement(4).getType())
        `EXPECT_EQ_DOUBLE(123.0, jv.getArrayElement(3).getNumber())
        `EXPECT_EQ_STRING("abc", jv.getArrayElement(4).getString())

        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads("[ [ ] , [ 0 ] , [ 0 , 1 ] , [ 0 , 1 , 2 ] ]"));
        `EXPECT_EQ_INT(JSONValue::JSON_ARRAY, jv.getType())
        `EXPECT_EQ_STRING("JSON_ARRAY", jv.getTypeString())
        `EXPECT_EQ_INT(4, jv.getArraySize())
        for (int i=0; i<4; i++) begin
            JSONValue tmp_jv;
            tmp_jv = jv.getArrayElement(i);
            `EXPECT_EQ_INT(JSONValue::JSON_ARRAY, tmp_jv.getType())
            `EXPECT_EQ_INT(i, tmp_jv.getArraySize())
            for (int j=0; j<i; j++) begin
                JSONValue tmp_jv_j = tmp_jv.getArrayElement(j);
                `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, tmp_jv_j.getType())
                `EXPECT_EQ_DOUBLE(real'(j), tmp_jv_j.getNumber())
            end
        end

        `REPORT_TEST()
    endtask: test
endclass: json_array_test 

