//
//File: JSONUtils.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:35:45
//Description: utilities for JSON lib
//Revisions: 
//2021/1/26 7:35:59: created
//

class JSONContext;
    
    function new(string json_txt = "NULL");
        this.json_txt = json_txt;
        this.current_idx = 0;
    endfunction

    // internal properties
    protected string json_txt;
    protected int current_idx;

    // APIs
    extern function byte peekChar();
    extern function byte popChar();
    extern function int getIndex();
    extern function void incIndex();
    extern function string getSubString(int idx_st, int idx_end);
    extern function void skipWhiteSpace();
    extern function bit isEnd();

endclass: JSONContext

function int JSONContext::getIndex ();
    return current_idx;
endfunction: JSONContext::getIndex

function void JSONContext::incIndex ();
    current_idx++;
endfunction: JSONContext::incIndex

function byte JSONContext::peekChar ();
    return this.json_txt[this.current_idx];
endfunction: JSONContext::peekChar

function byte JSONContext::popChar ();
    return this.json_txt[this.current_idx++];
endfunction: popChar

function string JSONContext::getSubString (
    int idx_st, int idx_end
);
    return this.json_txt.substr(idx_st, idx_end);
endfunction: JSONContext::getSubString

function void JSONContext::skipWhiteSpace ();
    while( this.json_txt[this.current_idx] inside {
        8'h20, // white space
        8'h09, // tab
        8'h0a, // \n
        8'h0d  // \r 
    }) begin
        this.current_idx++;
    end
endfunction: skipWhiteSpace

function bit JSONContext::isEnd ();
    return this.current_idx >= this.json_txt.len();
endfunction: JSONContext::isEnd

