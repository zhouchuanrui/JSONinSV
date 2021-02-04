//
//File: JSONValue.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:36:07
//Description: JSON value
//Revisions: 
//2021/1/26 7:36:46: created
//

typedef class JSONContext;

// the JSON value class
class JSONValue;

    // JSON type enumerate
    typedef enum {
        JSON_OBJECT,
        JSON_ARRAY,
        JSON_STRING, 
        JSON_NUMBER, 
        JSON_TRUE,
        JSON_FALSE,
        JSON_NULL
    } JSONType;
    JSONType this_type;

    function new(depth = 0, );
        this_type = JSON_NULL;
        this_depth = 0;
    endfunction

    // internal properties
    protected JSONValue this_object[string];
    protected JSONValue this_array[$];
    protected string this_string;
    protected real this_number;
    protected int this_depth; // depth of this value node, starts from 0

    // APIs
    extern JSONType getType();
    extern string getTypeString();

    extern void setNull();
    extern void setTrue();
    extern void setFalse();
    extern void setNumber(real number);
    extern void setString(string str);
    extern void setObject();
    extern void addMemberToObject(string key, JSONValue val);
    extern void setArray();
    extern void addValueToArray();

    // parser APIs
    extern JSONStatus loads(string json_txt);
    extern JSONStatus loadFromFile(string json_file);

    // dumper APIs
    extern JSONStatus dumps(ref string json_txt);
    extern JSONStatus dumpToFile(string json_file);

    // internal methods
    extern JSONStatus parseValue(JSONContext jc);
    extern JSONStatus parseObject(JSONContext jc);
    extern JSONStatus parseArray(JSONContext jc);
    extern JSONStatus parseString(JSONContext jc);
    extern JSONStatus parseNumber(JSONContext jc);
    extern JSONStatus parseNull(JSONContext jc);
    extern JSONStatus parseTrue(JSONContext jc);
    extern JSONStatus parseFalse(JSONContext jc);

endclass: JSONValue

function JSONStatus JSONValue::loads (string json_txt);
    JSONStatus ret;
    JSONContext ctx = new(json_txt);
    ctx.skipWhiteSpace();
    ret = parseValue(ctx);
    if (ret == PARSE_OK) begin
        ctx.skipWhiteSpace();
        if (ctx.isEnd() == 0) begin
            ret = PARSE_ROOT_NOT_SINGULAR;
        end
    end
    return ret;
endfunction

int lept_parse(lept_value* v, const char* json) {
    lept_context c;
    int ret;
    assert(v != NULL);
    c.json = json;
    c.stack = NULL;
    c.size = c.top = 0;
    lept_init(v);
    lept_parse_whitespace(&c);
    if ((ret = lept_parse_value(&c, v)) == LEPT_PARSE_OK) {
        lept_parse_whitespace(&c);
        if (*c.json != '\0') {
            v->type = LEPT_NULL;
            ret = LEPT_PARSE_ROOT_NOT_SINGULAR;
        }
    }
    assert(c.top == 0);
    free(c.stack);
    return ret;
}
