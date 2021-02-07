//
//File: json_pkg.sv
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:31:56
//Description: JSON lib compilation package
//Revisions: 
//2021/1/26 7:32:13: created
//

package json_pkg;
    `include "json_macros.svh"

    // JSON status enumerate
    typedef enum {
        PARSE_OK = 0,
        PARSE_ROOT_NOT_SINGULAR,
        PARSE_INVALID_VALUE,
        PARSE_MISS_QUOTATION_MARK,
        PARSE_MISS_COMMA_OR_SQUARE_BRACKET,
        PARSE_NO_VALUE,
        RSV
    } JSONStatus;

    `include "JSONUtils.svh"
    `include "JSONValue.svh"
endpackage

