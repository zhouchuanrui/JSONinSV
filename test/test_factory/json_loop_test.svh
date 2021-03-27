//
//File: json_loop_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/3/27 22:05:36
//Description: loop test for json
//Revisions: 
//2021/3/27 22:05:52: created
//

class json_loop_test extends json_string_test;
    `__register(json_loop_test)

    function void json_loop_test (
        string str
    );
        string str_o;
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(json_pkg::PARSE_OK, jv.loads(str))
        `EXPECT_EQ_INT(json_pkg::DUMP_OK, jv.dumps(str_o))
        `EXPECT_EQ_STRING(str, str_o)
    endfunction

    task test ();
        $display("Start JSON loop test..");

        json_loop_test("null");
        json_loop_test("false");
        json_loop_test("true");

        json_loop_test("0");
        json_loop_test("-0");
        json_loop_test("1");
        json_loop_test("-1");
        json_loop_test("1.5");
        json_loop_test("-1.5");
        json_loop_test("3.25");
        json_loop_test("1e+20");
        json_loop_test("1.234e+20");
        json_loop_test("1.234e-20");

        json_loop_test("1.0000000000000002"); /* the smallest number > 1 */
        json_loop_test("4.9406564584124654e-324"); /* minimum denormal */
        json_loop_test("-4.9406564584124654e-324");
        json_loop_test("2.2250738585072009e-308");  /* Max subnormal double */
        json_loop_test("-2.2250738585072009e-308");
        json_loop_test("2.2250738585072014e-308");  /* Min normal positive double */
        json_loop_test("-2.2250738585072014e-308");
        json_loop_test("1.7976931348623157e+308");  /* Max double */
        json_loop_test("-1.7976931348623157e+308");

        json_loop_test("\"\"");
        json_loop_test("\"Hello\"");

        json_loop_test("[]");
        json_loop_test("[null, false, true, 123, \"abc\", [1, 2, 3]]");

        json_loop_test("{}");
        // a associative array implementation of object does not keep 
        // input key order
        //json_loop_test("{\"n\": null, \"f\": false, \"t\": true, \"i\": 123, \"s\": \"abc\", \"a\": [1, 2, 3], \"o\": {\"1\": 1, \"2\": 2, \"3\": 3}}");

        `REPORT_TEST()
    endtask

endclass

