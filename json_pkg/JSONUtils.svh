//
//File: JSONUtils.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:35:45
//Description: utilities for JSON lib
//Revisions: 
//2021/1/26 7:35:59: created
//

typedef class JSONValue;

class JSONContext;
    
    function new(string json_txt = "NULL");
        this.json_txt = json_txt;
        this.current_idx = 0;
    endfunction

    // internal properties
    protected string json_txt;
    //string json_buf;
    protected int current_idx;

    // APIs
    extern byte peekChar();
    extern byte popChar();
    extern string getSubString(int idx_st, int idx_end);
    extern void skipWhiteSpace();

endclass: JSONContext

function byte JSONContext::peekChar ();
    return this.json_txt[this.current_idx];
endfunction: JSONContext::peekChar

function byte JSONContext::popChar ();
    return this.json_txt[this.current_idx++];
endfunction: popChar

function string JSONContext::getSubString (
    int idx_st, int idx_end
);
    return this.json_txt.substr(current_idx+idx_st, current_idx+idx_end);
endfunction: JSONContext::getSubString

function void JSONContext::skipWhiteSpace ();
    while( peekChar() inside [
        8'h20, // white space
        8'h09, // tab
        8'h0a, // \n
        8'h0d  // \r 
    ]) begin
        current_idx++;
    end
endfunction: skipWhiteSpace

static void lept_parse_whitespace(lept_context* c) {
    const char *p = c->json;
    while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r')
        p++;
    c->json = p;
}

class JSONTop;

    function new();
    endfunction

    // parser APIs
    extern JSONStatus loads(string json_txt);
    extern JSONStatus loadFromFile(string json_file);

    // dumper APIs
    extern JSONStatus dumps(ref string json_txt);
    extern JSONStatus dumpToFile(string json_file);

    // internal properties
    extern JSONStatus parseValue(JSONValue jv, JSONContext jc);
    extern JSONStatus parseWhiteSpace(JSONContext jc);
    extern JSONStatus parseObject(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseArray(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseString(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseNumber(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseNull(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseTrue(JSONStatus jv, JSONContext jc);
    extern JSONStatus parseFalse(JSONStatus jv, JSONContext jc);

endclass: JSONTop

function JSONStatus JSONTop::loads (string json_txt);
endfunction

