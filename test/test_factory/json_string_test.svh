//
//File: json_string_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/28 15:10:15
//Description: string test for json
//Revisions: 
//2021/2/28 15:10:25: created
//

class json_string_test extends TestPrototype;
    `__register(json_string_test)
    
    function void testString (
        string exp, string json
    );
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads(json));
        `EXPECT_EQ_INT(JSONValue::JSON_STRING, jv.getType());
        `EXPECT_EQ_STRING("JSON_STRING", jv.getTypeString());
        `EXPECT_EQ_STRING(exp, jv.getString());
        /*
        * exp != jv.getString()
        * while each byte equals
        * ..
        *
        if(exp != jv.getString()) begin
            string act = jv.getString();
            $display("exp len: %0d, act len: %0d", exp.len(), act.len());
            foreach(exp[i]) begin
                $display("exp[%0d] = %c %x, act[%0d] = %c %x", 
                    i, exp[i], exp[i],
                    i, act[i], act[i]);
            end
        end
        * */
    endfunction: testString

    task test ();
        $display("Start JSON string test..");
        testString("", "\"\"");
        testString("hello", "\"hello\"");
        testString("Hello\nWorld", "\"Hello\nWorld\"");
        `REPORT_TEST()
    endtask: test

endclass

