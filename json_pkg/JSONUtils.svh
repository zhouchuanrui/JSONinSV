//
//File: JSONUtils.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:35:45
//Description: utilities for JSON lib
//Revisions: 
//2021/1/26 7:35:59: created
//

`ifndef __JSONUTILS_SVH__
`define __JSONUTILS_SVH__

class JSONContext;
    
    function new(string json_txt = "NULL");
        this.json_txt = json_txt;
        this.current_idx = 0;
    endfunction

    // internal properties
    protected string json_txt;
    protected int current_idx;

    // APIs
    extern virtual function byte peekChar();
    extern virtual function byte popChar();
    extern virtual function int getIndex();
    extern virtual function void incIndex();
    extern virtual function string getSubString(int idx_st, int idx_end);
    extern virtual function void skipWhiteSpace();
    extern virtual function bit isEnd();

endclass

typedef class JSONValue;

class JSONStringBuffer;

    function new(int unsigned indent = 0);
        this.indent = indent;
    endfunction

    // internal properties
    protected int unsigned indent;
    //protected byte str_q[$];
    protected string str_q;

    // APIs
    extern virtual function string getString();
    extern virtual function void pushString(string str);
    // push interpreted string:
    // " to /"
    // / to //
    extern virtual function void pushRawString(string str); 
    extern virtual function void addIndents(int unsigned level); 
endclass


function int JSONContext::getIndex ();
    return current_idx;
endfunction

function void JSONContext::incIndex ();
    current_idx++;
endfunction

function byte JSONContext::peekChar ();
    return this.json_txt[this.current_idx];
endfunction

function byte JSONContext::popChar ();
    return this.json_txt[this.current_idx++];
endfunction

function string JSONContext::getSubString (
    int idx_st, int idx_end
);
    return this.json_txt.substr(idx_st, idx_end);
endfunction

function void JSONContext::skipWhiteSpace ();
    while( this.json_txt[this.current_idx] inside {
        8'h20, // white space
        8'h09, // tab
        8'h0a, // \n
        8'h0d  // \r 
    }) begin
        this.current_idx++;
    end
endfunction

function bit JSONContext::isEnd ();
    return this.current_idx >= this.json_txt.len();
endfunction

function string JSONStringBuffer::getString ();
    /*
    *
    string str;
    str = {>>{str_q}};
    return str;
    * */
    return str_q;
endfunction

function void JSONStringBuffer::pushString (
    string str
);
    /*
    *
    for (int i=0; i<str.len(); i++) begin
        str_q.push_back(str.getc[i]);
    end
    * */
    str_q = {str_q, str};
endfunction

function void JSONStringBuffer::pushRawString (
    string str
);
    byte ch_q[$];
    string tmp_str;
    ch_q.push_back("\"");
    // " to /"
    // / to //
    for(int i=0; i<str.len(); i++) begin
        if (str[i] == 8'h22 || str[i] == 8'h2f) begin
            ch_q.push_back(8'h2f); // push '/'
        end
        ch_q.push_back(str[i]);
    end
    ch_q.push_back("\"");
    tmp_str = {>>{ch_q}};
    str_q = {str_q, tmp_str};
endfunction

function void JSONStringBuffer::addIndents (int unsigned level);
    byte ch_q[$];
    string tmp_str;
    if (indent == 0) begin
        return;
    end
    ch_q.push_back("\n");
    repeat(level*indent) begin
        ch_q.push_back(" ");
    end
    tmp_str = {>>{ch_q}};
    str_q = {str_q, tmp_str};
endfunction

// developing class
class JSONChecker;

    function new(int depth=0);
    endfunction

    // internal properties
    protected JSONValue jv_oa_q[$]; // store handles of objects, arrays
    protected int current_depth;

    // APIs
endclass

`endif

