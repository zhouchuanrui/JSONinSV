//
//File: json_macros.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:30:57
//Description: Macros for JSON lib
//Revisions: 
//2021/1/26 7:31:43: created
//

`define JSON_LOG(prt_str)  \
$display({"[JSON_LOG]", prt_str});

`define JSON_WARN(prt_str) \
$display({"[JSON_WARN]", prt_str});

`define JSON_ERROR(prt_str) \
$display({"[JSON_ERROR]", prt_str});

`define JSON_FATAL(prt_str) \
$display({"[JSON_FATAL]", prt_str});

