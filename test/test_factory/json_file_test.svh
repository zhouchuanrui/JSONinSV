//
//File: json_file_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/3/9 7:33:01
//Description: file test
//Revisions: 
//2021/3/9 7:33:13: created
//

class json_file_test extends TestPrototype;
    `__register(json_file_test)

    task test ();
        JSONValue jv;
        string base_dir;
        jv = new();

        $display("Start file test..");

        if ($value$plusargs("DIR=%s", base_dir)) begin
            $display("Set test directory to %s", base_dir);
        end else begin
            base_dir = "../";
            $display("Use %s as test directory..", base_dir);
        end

        //`EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loadFromFile("../test/json_files/object.json"))
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loadFromFile({base_dir, "/test/json_files/object.json"}))
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
        `EXPECT_EQ_INT(3, jv.getObjectMember("o").getObjectSize())
        for (int i=0; i<3; i++) begin
            JSONValue this_val;
            this_val = jv.getObjectMember("o").getObjectMember($sformatf("%0d", i+1));
            `EXPECT_EQ_INT(JSONValue::JSON_NUMBER, this_val.getType())
            `EXPECT_EQ_DOUBLE(i+1.0, this_val.getNumber())
        end

        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/dumped_object.json"}))
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/dumped_object_i2.json"}, 2))
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/dumped_object_i4.json"}, 4))

        begin
            JSONValue _jvo, jv_o, jv_str, jv_num;

            _jvo = jv.getObjectMember("o");
            jv_o = _jvo.createMemberOfObject("inner_obj", JSONValue::JSON_OBJECT);
            //jv_o = new(2);
            //jv_o.setObject();
            //jv.addMemberToObject("inner_obj", jv_o);
            //_jvo.addMemberToObject("inner_obj", jv_o);
            //jv_str = new(3);
            jv_str = jv_o.createMemberOfObject("auth", JSONValue::JSON_STRING);
            jv_str.setString("zcr");
            //jv_num = new(3);
            jv_num = jv_o.createMemberOfObject("grade", JSONValue::JSON_NUMBER);
            jv_num.setNumber(5);
            //jv_o.addMemberToObject("auth", jv_str);
            //jv_o.addMemberToObject("grade", jv_num);
        end
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/modified_object.json"}))
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/modified_object_i2.json"}, 2))
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumpToFile({base_dir, "/test/json_files/modified_object_i4.json"}, 4))

        `REPORT_TEST()
    endtask

endclass

