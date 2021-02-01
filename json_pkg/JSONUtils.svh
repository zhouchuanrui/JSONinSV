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
    
    string json_txt;
    //string json_buf;
    int current_idx;

    function new(string json_txt = "NULL");
        this.json_txt = json_txt;
        this.current_idx = 0;
    endfunction

endclass: JSONContext


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
    protected int this_depth; // depth of this value node, starts from 0
    extern JSONStatus parseValue();
    extern JSONStatus parseWhiteSpace();
    extern JSONStatus parseObject();
    extern JSONStatus parseArray();
    extern JSONStatus parseString();
    extern JSONStatus parseNumber();
    extern JSONStatus parseNull();
    extern JSONStatus parseTrue();
    extern JSONStatus parseFalse();

endclass: JSONTop

function JSONStatus JSONTop::loads (string json_txt);
endfunction

