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

    static const string null_literal = "null";
    static const string true_literal = "true";
    static const string false_literal = "false";
    
    function new(depth = 0);
        this_type = JSON_NULL;
        this_depth = depth;
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

function JSONStatus JSONValue::parseValue (JSONContext jc);
    if (jc.isEnd()) begin
        return PARSE_NO_VALUE;
    end
    case(jc.peekChar())
        "t": return parseTrue(jc);
        "f": return parseFalse(jc);
        "n": return parseNull(jc);
        "\"": return parseString(jc);
        "[": return parseArray(jc);
        "{": return parseObject(jc);
        default: return parseNumber(jc);
    endcase
endfunction: JSONValue::parseValue

function JSONStatus JSONValue::parseTrue (JSONContext jc);
    for (int i=0; i < true_literal.len(); i++) begin
        if (jc.popChar() != true_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setTrue();
endfunction: JSONValue::parseTrue

function JSONStatus JSONValue::parseFalse (JSONContext jc);
    for (int i=0; i < false_literal.len(); i++) begin
        if (jc.popChar() != false_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setFalse();
endfunction: JSONValue::parseFalse

function JSONStatus JSONValue::parseNull (JSONContext jc);
    for (int i=0; i < null_literal.len(); i++) begin
        if (jc.popChar() != null_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setNull();
endfunction: JSONValue::parseNull

function JSONStatus JSONValue::parseNumber (
    JSONContext jc
);
    int idx_st, idx_end;
    byte this_char;
    idx_st = jc.getIndex();
    if (jc.peekChar() == "-") begin
        jc.incIndex();
    end
    `define _isDigit(_ch) ((_ch) >= "0" && (_ch) <= "9")

    if (jc.peekChar() == "0") begin
        jc.incIndex();
    end else begin
        this_char = jc.popChar();
        // following char should be inside {"1" ~ "9"}
        if (!(this_char >= "1" && this_char <= "9")) begin
            return PARSE_INVALID_VALUE;
        end
        while (_isDigit(jc.peekChar())) begin
            jc.incIndex();
        end
    end
    if (jc.peekChar() == ".") begin
        jc.incIndex();
        if (!_isDigit(jc.popChar())) begin
            return PARSE_INVALID_VALUE;
        end
        while (_isDigit(jc.peekChar())) begin
            jc.incIndex();
        end
    end
    this_char = jc.peekChar();
    if (this_char == "e" || this_char == "E") begin
        jc.incIndex();
        this_char = jc.peekChar();
        if (this_char == "+" || this_char == "-") begin
            jc.incIndex();
        end
        this_char = jc.popChar();
        if (!_isDigit(this_char)) begin
            return PARSE_INVALID_VALUE;
        end
        while (_isDigit(jc.peekChar())) begin
            jc.incIndex();
        end
    end
    idx_end = jc.getIndex();
    this.setNumber(jc.getSubString(idx_st, idx_end).atoreal());
    return PARSE_OK;
    `undef _isDigit
endfunction: JSONValue::parseNumber

function JSONStatus JSONValue::parseString (
    JSONContext jc
);
    
endfunction: JSONValue::parseString

static int lept_parse_array(lept_context* c, lept_value* v) {
    size_t i, size = 0;
    int ret;
    EXPECT(c, '[');
    lept_parse_whitespace(c);
    if (*c->json == ']') {
        c->json++;
        lept_set_array(v, 0);
        return LEPT_PARSE_OK;
    }
    for (;;) {
        lept_value e;
        lept_init(&e);
        if ((ret = lept_parse_value(c, &e)) != LEPT_PARSE_OK)
            break;
        memcpy(lept_context_push(c, sizeof(lept_value)), &e, sizeof(lept_value));
        size++;
        lept_parse_whitespace(c);
        if (*c->json == ',') {
            c->json++;
            lept_parse_whitespace(c);
        }
        else if (*c->json == ']') {
            c->json++;
            lept_set_array(v, size);
            memcpy(v->u.a.e, lept_context_pop(c, size * sizeof(lept_value)), size * sizeof(lept_value));
            v->u.a.size = size;
            return LEPT_PARSE_OK;
        }
        else {
            ret = LEPT_PARSE_MISS_COMMA_OR_SQUARE_BRACKET;
            break;
        }
    }
    /* Pop and free values on the stack */
    for (i = 0; i < size; i++)
        lept_free((lept_value*)lept_context_pop(c, sizeof(lept_value)));
    return ret;
}

function JSONStatus JSONValue::parseArray (
    JSONContext jc
);
    JSONStatus ret;
    this.setArray();
    jc.incIndex();
    jc.skipWhiteSpace();
    if (jc.peekChar() == "]") begin
        jc.incIndex();
        return PARSE_OK;
    end
    JSONValue val;
    while (1) begin
        val = new(this_depth+1);
        ret = parseValue(jc);
        if (ret != PARSE_OK) begin
            break;
        end
        jc.skipWhiteSpace();
        if (jc.peekChar() == ",") begin
            jc.incIndex();
            jc.skipWhiteSpace();
        end else if (jc.peekChar() == "]") begin
            jc.incIndex();
            return PARSE_OK;
        end else begin
            ret = PARSE_MISS_COMMA_OR_SQUARE_BRACKET;
            break;
        end
    end
    return ret;
endfunction: JSONValue::parseArray


function void JSONValue::setNull ();
    this_type = JSON_NULL;
endfunction: JSONValue::setNull

function void JSONValue::setTrue ();
    this_type = JSON_TRUE;
endfunction: JSONValue::setTrue

function void JSONValue::setFalse ();
    this_type = JSON_FALSE;
endfunction: JSONValue::setFalse

function void JSONValue::setNumber (
    real number
);
    this_type = JSON_NUMBER;
    this_number = number;
endfunction: JSONValue::setNumber

function void JSONValue::setString (
    string str
);
    this_type = JSON_STRING;
    this_string = str;
endfunction: JSONValue::setString

function void JSONValue::setObject ();
    this_type = JSON_OBJECT;
endfunction: setObject 

function void JSONValue::addMemberToObject (
    string key, JSONValue val
);
    if (this_object.exists(key)) begin
        `JSON_WARN("Member with key: %s exists in this object. Parser would override it!!", key)
    end
    this_object[key] = value;
endfunction: JSONValue::addMemberToObject

function void JSONValue::setArray ();
    this_type = JSON_ARRAY;
endfunction: JSONValue::setArray

function void JSONValue::addValueToArray (
    JSONValue val
);
    this_array.push_back(val);
endfunction: JSONValue::addval

