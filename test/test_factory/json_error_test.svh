//
//File: json_error_test.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/3/27 21:44:53
//Description: error enum test for json
//Revisions: 
//2021/3/27 21:45:13: created
//

class json_error_test extends json_string_test;
    `__register(json_error_test)

    function void json_test_error (
        json_pkg::JSONStatus err,
        string json_txt
    );
        JSONValue jv;
        jv = new();
        `EXPECT_EQ_INT(err, jv.loads(json_txt));
        `EXPECT_EQ_INT(JSONValue::JSON_NULL, jv.getType());
    endfunction

    task test ();
        $display("Start JSON error test..");

        json_test_error(json_pkg::PARSE_NO_VALUE, "");
        json_test_error(json_pkg::PARSE_NO_VALUE, " ");

        json_test_error(json_pkg::PARSE_INVALID_VALUE, "nul");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "?");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "+0");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "+1");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, ".123");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "1.");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "[1, ]");
        json_test_error(json_pkg::PARSE_INVALID_VALUE, "[1, nul]");

        json_test_error(json_pkg::PARSE_ROOT_NOT_SINGULAR, "null a");
        json_test_error(json_pkg::PARSE_ROOT_NOT_SINGULAR, "0x0");
        json_test_error(json_pkg::PARSE_ROOT_NOT_SINGULAR, "0xfe");
        json_test_error(json_pkg::PARSE_ROOT_NOT_SINGULAR, "0123");

        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_SQUARE_BRACKET, "[1");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_SQUARE_BRACKET, "[1}");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_SQUARE_BRACKET, "[1 2");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_SQUARE_BRACKET, "[[]");

        json_test_error(json_pkg::PARSE_MISS_KEY, "{:1, ");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{1:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{true:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{false:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{null:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{[]:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{{}:1,");
        json_test_error(json_pkg::PARSE_MISS_KEY, "{\"a\":1,");

        json_test_error(json_pkg::PARSE_MISS_COLON, "{\"a\"}");
        json_test_error(json_pkg::PARSE_MISS_COLON, "{\"a\",\"b\"}");

        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_CURLY_BRACKET, "{\"a\":1");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_CURLY_BRACKET, "{\"a\":1]");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_CURLY_BRACKET, "{\"a\":1 \"b\"");
        json_test_error(json_pkg::PARSE_MISS_COMMA_OR_CURLY_BRACKET, "{\"a\":{}");

        `REPORT_TEST()
    endtask

endclass

