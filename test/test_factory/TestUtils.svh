//
//File: TestUtils.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/2/21 7:47:03
//Description: test utilities, including test counter class and assertion marcos
//Revisions: 
//2021/2/21 7:47:16: created
//

class TestStat;
    static int pass_cnt = 0, fail_cnt = 0;

    static function void report ();
        $display("[RPT]test done with %0d PASSs, %0d FAILs", pass_cnt, fail_cnt);
    endfunction: report
endclass

`define REPORT_TEST(args) TestStat::report();

`define EXPECT_EQ_BASE(equality, expect, actual, format) \
do begin \
    if ((equality) == 1) begin \
        TestStat::pass_cnt++; \
    end else begin \
        TestStat::fail_cnt++; \
        $display($sformatf("[ASSERT_FAIL] expect: %s actual %s", format, format), expect, actual); \
    end \
end while(0);

`define EXPECT_EQ_INT(expect, actual) `EXPECT_EQ_BASE((expect)==(actual), expect, actual, "%d")
`define EXPECT_EQ_DOUBLE(expect, actual) `EXPECT_EQ_BASE((expect)==(actual), expect, actual, "%.17g")

function bit strEqu (
    string lhs, rhs
);
    if (lhs.len() != rhs.len()) begin
        return 0;
    end
    foreach(lhs[i]) begin
        if (lhs[i] != rhs[i]) begin
            return 0;
        end
    end
    return 1;
endfunction: strEqu
`define EXPECT_EQ_STRING(expect, actual) `EXPECT_EQ_BASE((strEqu(expect, actual)), expect, actual, "%s")

`define EXPECT_NEQ_BASE(equality, expect, actual, format) \
do begin \
    if ((equality) == 0) begin \
        TestStat::pass_cnt++; \
    end else begin \
        TestStat::fail_cnt++; \
        $display({"[ASSERT_FAIL]", "expect: ", format, " actual: ", format}, expect, actual); \
    end \
end while(0);

`define EXPECT_NEQ_INT(expect, actual) `EXPECT_NEQ_BASE((expect)==(actual), expect, actual, "%d")
`define EXPECT_NEQ_DOUBLE(expect, actual) `EXPECT_NEQ_BASE((expect)==(actual), expect, actual, "%.17g")
`define EXPECT_NEQ_STRING(expect, actual) `EXPECT_NEQ_BASE((expect)==(actual), expect, actual, "%s")

