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
        $display("Start JSON number test..");
        testNumber(0.0, "0");
        testNumber(0.0, "-0");
        testNumber(0.0, "-0.0");
        testNumber(1.0, "1");
        testNumber(-1.0, "-1");
        //testNumber(0.0, "-1");
        testNumber(1.5, "1.5");
        testNumber(-1.5, "-1.5");
        testNumber(3.1416, "3.1416");
        testNumber(1E10, "1E10");
        testNumber(1e10, "1e10");
        testNumber(1E+10, "1E+10");
        testNumber(1E-10, "1E-10");
        testNumber(-1E10, "-1E10");
        testNumber(-1e10, "-1e10");
        testNumber(-1E+10, "-1E+10");
        testNumber(-1E-10, "-1E-10");
        testNumber(1.234E+10, "1.234E+10");
        testNumber(1.234E-10, "1.234E-10");
        testNumber(0.0, "1e-10000"); /* must underflow */
        testNumber(1.0000000000000002, "1.0000000000000002"); /* the smallest number > 1 */
        testNumber( 4.9406564584124654e-324, "4.9406564584124654e-324"); /* minimum denormal */
        testNumber(-4.9406564584124654e-324, "-4.9406564584124654e-324");
        testNumber( 2.2250738585072009e-308, "2.2250738585072009e-308");  /* Max subnormal double */
        testNumber(-2.2250738585072009e-308, "-2.2250738585072009e-308");
        testNumber( 2.2250738585072014e-308, "2.2250738585072014e-308");  /* Min normal positive double */
        testNumber(-2.2250738585072014e-308, "-2.2250738585072014e-308");
        testNumber( 1.7976931348623157e+308, "1.7976931348623157e+308");  /* Max double */
        testNumber(-1.7976931348623157e+308, "-1.7976931348623157e+308");
        `REPORT_TEST()
    endtask: test

endclass: json_number_test

