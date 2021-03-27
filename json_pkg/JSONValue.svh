//
//File: JSONValue.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:36:07
//Description: JSON value
//Revisions: 
//2021/1/26 7:36:46: 
//  created
//2021/3/1 23:27:36: 
//  fix M-tool issue by doing strsub in addMemberToObject
//
//2021/3/9 0:01:08: 
//  update loadFromFile; TODO:
//  testdir dealing
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
    
    // internal properties
    protected JSONValue this_object[string];
    protected JSONValue this_array[$];
    protected string this_string;
    protected real this_number;
    protected int this_depth; // depth of this value node, starts from 0

    function new(int depth = 0);
        this_type = JSON_NULL;
        this_depth = depth;
    endfunction

    // APIs
    extern function JSONType getType();
    extern function string getTypeString();

    extern function void setNull();
    extern function void setTrue();
    extern function void setFalse();
    extern function void setNumber(real number);
    extern function void setString(string str);
    extern function void setObject();
    extern function void addMemberToObject(string key, JSONValue val);
    extern function void setArray();
    extern function void addValueToArray(JSONValue val);

    extern function real getNumber ();
    extern function string getString ();
    extern function int getArraySize ();
    extern function JSONValue getArrayElement (int idx);
    extern function int getObjectSize ();
    extern function JSONValue getObjectMember (string key);

    // parser APIs
    extern function JSONStatus loads(string json_txt);
    extern function JSONStatus loadFromFile(string json_file);

    // dumper APIs
    extern function JSONStatus dumps(output string json_txt, input int unsigned indent = 0);
    extern function JSONStatus dumpToFile(string json_file, int unsigned indent=0);

    // internal methods
    // parse 
    extern function JSONStatus parseValue(JSONContext jc);
    extern function JSONStatus parseObject(JSONContext jc);
    extern function JSONStatus parseArray(JSONContext jc);
    extern function JSONStatus parseString(JSONContext jc);
    extern function JSONStatus parseNumber(JSONContext jc);
    extern function JSONStatus parseNull(JSONContext jc);
    extern function JSONStatus parseTrue(JSONContext jc);
    extern function JSONStatus parseFalse(JSONContext jc);
    extern function JSONStatus parseStringLiteral(JSONContext jc, output string str);
    // check
    extern function JSONStatus checkLoop(JSONChecker jc, int valid_depth=0);
    // stringify 
    extern function JSONStatus toString(JSONStringBuffer jsb);

endclass

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
/*
* */

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
endfunction

function JSONStatus JSONValue::parseTrue (JSONContext jc);
    for (int i=0; i < true_literal.len(); i++) begin
        if (jc.popChar() != true_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setTrue();
    return PARSE_OK;
endfunction

function JSONStatus JSONValue::parseFalse (JSONContext jc);
    for (int i=0; i < false_literal.len(); i++) begin
        if (jc.popChar() != false_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setFalse();
    return PARSE_OK;
endfunction

function JSONStatus JSONValue::parseNull (JSONContext jc);
    for (int i=0; i < null_literal.len(); i++) begin
        if (jc.popChar() != null_literal[i]) begin
            return PARSE_INVALID_VALUE;
        end
    end
    this.setNull();
    return PARSE_OK;
endfunction

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
        while (`_isDigit(jc.peekChar())) begin
            jc.incIndex();
        end
    end
    if (jc.peekChar() == ".") begin
        jc.incIndex();
        //if (!`_isDigit(jc.popChar())) begin 
        // fix: this would call popChar() twice in macro expansion
        //
        if (!`_isDigit(jc.peekChar())) begin
            return PARSE_INVALID_VALUE;
        end
        while (`_isDigit(jc.peekChar())) begin
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
        if (!`_isDigit(this_char)) begin
            return PARSE_INVALID_VALUE;
        end
        while (`_isDigit(jc.peekChar())) begin
            jc.incIndex();
        end
    end
    idx_end = jc.getIndex();
    begin
        string real_str;
        real_str = jc.getSubString(idx_st, idx_end-1);
        this.setNumber(real_str.atoreal());
    end
    return PARSE_OK;
    `undef _isDigit
endfunction

function JSONStatus JSONValue::parseStringLiteral (
    JSONContext jc,
    output string str
);
    byte str_q[$];
    byte this_char;
    jc.incIndex();
    while (1) begin
        this_char = jc.popChar();
        case(this_char)
            "\"": begin
                //str_q.push_back(0);
                //void'(str_q.pop_back());
                str = {>>{str_q}};
                return PARSE_OK;
            end
            "\\": begin // back-slash parse
                this_char = jc.popChar();
                case (this_char) 
                    "\"": begin
                        str_q.push_back(this_char);
                    end
                    "\n": begin
                        str_q.push_back(this_char);
                    end
                    "\\": begin
                        str_q.push_back(this_char);
                    end
                    "\t": begin
                        str_q.push_back(this_char);
                    end
                    "\f": begin
                        str_q.push_back(this_char);
                    end
                endcase
            end
            0: begin
                if (jc.isEnd()) begin
                    return PARSE_MISS_QUOTATION_MARK;
                end
            end
            default: begin
                str_q.push_back(this_char);
            end
        endcase
    end
endfunction

function JSONStatus JSONValue::parseString (
    JSONContext jc
);
    JSONStatus ret;
    string str;
    ret = parseStringLiteral(jc, str);
    if (ret == PARSE_OK) begin
        setString(str);
    end
    return ret;
endfunction

function JSONStatus JSONValue::parseArray (
    JSONContext jc
);
    JSONStatus ret;
    JSONValue val;
    this.setArray();
    jc.incIndex();
    jc.skipWhiteSpace();
    if (jc.peekChar() == "]") begin
        jc.incIndex();
        return PARSE_OK;
    end
    while (1) begin
        val = new(this_depth+1);
        ret = val.parseValue(jc);
        if (ret != PARSE_OK) begin
            break;
        end
        this.addValueToArray(val);
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
endfunction

function JSONStatus JSONValue::parseObject (
    JSONContext jc
);
    string this_key;
    JSONValue val;
    JSONStatus ret;
    this.setObject();

    jc.incIndex();
    jc.skipWhiteSpace();
    if (jc.peekChar() == "}") begin
        jc.incIndex();
        return PARSE_OK;
    end
    while(1) begin
        if (jc.peekChar() != "\"") begin
            ret = PARSE_MISS_KEY;
            break;
        end
        val = new(this_depth+1);
        ret = parseStringLiteral(jc, this_key);
        this.addMemberToObject(this_key, val);
        if (ret != PARSE_OK) begin
            break;
        end
        jc.skipWhiteSpace();
        if (jc.peekChar() != ":") begin
            ret = PARSE_MISS_COLON;
            break;
        end
        jc.incIndex();
        jc.skipWhiteSpace();
        ret = val.parseValue(jc);
        if (ret != PARSE_OK) begin
            break;
        end
        jc.skipWhiteSpace();
        if (jc.peekChar() == ",") begin
            jc.incIndex();
            jc.skipWhiteSpace();
        end else if (jc.peekChar() == "}") begin
            jc.incIndex();
            return PARSE_OK;
        end else begin
            ret = PARSE_MISS_COMMA_OR_CURLY_BRACKET;
            break;
        end
    end
    return ret;
endfunction

function void JSONValue::setNull ();
    this_type = JSON_NULL;
endfunction

function void JSONValue::setTrue ();
    this_type = JSON_TRUE;
endfunction

function void JSONValue::setFalse ();
    this_type = JSON_FALSE;
endfunction

function void JSONValue::setNumber (
    real number
);
    this_type = JSON_NUMBER;
    this_number = number;
endfunction

function void JSONValue::setString (
    string str
);
    this_type = JSON_STRING;
    this_string = str;
endfunction

function void JSONValue::setObject ();
    this_type = JSON_OBJECT;
endfunction

function void JSONValue::addMemberToObject (
    string key, JSONValue val
);
    string _str;
    // M-tool need to do substr
    _str = key.substr(0, key.len()-1);

    if (this_object.exists(_str)) begin
        `JSON_WARN($sformatf("Member with key: %s exists in this object. Parser would override it!!", _str))
    end
    this_object[_str] = val;
endfunction

function void JSONValue::setArray ();
    this_type = JSON_ARRAY;
endfunction

function void JSONValue::addValueToArray (
    JSONValue val
);
    this_array.push_back(val);
endfunction

function JSONValue::JSONType JSONValue::getType ();
    return this_type;
endfunction

function string JSONValue::getTypeString ();
    return this_type.name();
endfunction

function real JSONValue::getNumber ();
    if (this_type != JSON_NUMBER) begin
        `JSON_ERROR($sformatf("Try to get number from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    return this_number;
endfunction

function string JSONValue::getString ();
    if (this_type != JSON_STRING) begin
        `JSON_ERROR($sformatf("Try to get string from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    return this_string;
endfunction

function int JSONValue::getArraySize ();
    if (this_type != JSON_ARRAY) begin
        `JSON_ERROR($sformatf("Try to get array size from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    return this_array.size();
endfunction

function JSONValue JSONValue::getArrayElement (
    int idx
);
    if (this_type != JSON_ARRAY) begin
        `JSON_ERROR($sformatf("Try to get array value from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    if (idx >= this_array.size()) begin
        `JSON_ERROR("Index out of array size!!")
    end
    return this_array[idx];
endfunction

function int JSONValue::getObjectSize ();
    if (this_type != JSON_OBJECT) begin
        `JSON_ERROR($sformatf("Try to get object size from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    return this_object.size();
endfunction

function JSONValue JSONValue::getObjectMember (
    string key
);
    if (this_type != JSON_OBJECT) begin
        `JSON_ERROR($sformatf("Try to get object member from JSON node with type: %s!!",
            this_type.name()
        ))
    end
    if (!this_object.exists(key)) begin
        `JSON_ERROR($sformatf("Non-exist key: %s in object", key))
        if (this_object.first(key)) begin
            do begin
                $display("this_object[\"%s\"] with type: %s", key, this_object[key].getTypeString());
            end while(this_object.next(key));
        end
    end
    return this_object[key];
endfunction

function JSONStatus JSONValue::loadFromFile (
    string json_file
);
    JSONStatus ret;
    string json_txt = "", this_line = "";
    int j_fd;
    j_fd = $fopen(json_file, "r");
    if (j_fd == 0) begin
        return FILE_OPEN_ERROR;
    end
    while($feof(j_fd) == 0) begin
        void'($fgets(this_line, j_fd));
        json_txt = {json_txt, this_line};
    end
    ret = this.loads(json_txt);
    $fclose(j_fd);
    return ret;
endfunction

function JSONStatus JSONValue::dumps (
    output string json_txt,
    input int unsigned indent = 0
);
    JSONStatus ret;
    JSONStringBuffer jsb = new(indent);
    JSONChecker jc = new();
    json_txt = "";
    ret = this.checkLoop(jc, this_depth);
    if (ret != CHECK_OK) begin
        return ret;
    end
    ret = this.toString(jsb);
    if (ret != STRINGIFY_OK) begin
        return ret;
    end
    json_txt = jsb.getString();
    return DUMP_OK;
endfunction

function JSONStatus JSONValue::checkLoop (
    JSONChecker jc,
    int valid_depth = 0
);
    return CHECK_OK;
endfunction

function JSONStatus JSONValue::toString (JSONStringBuffer jsb);
    JSONStatus ret = STRINGIFY_OK;
    case(this_type) 
        JSON_NULL: begin
            jsb.pushString("null");
        end
        JSON_FALSE: begin
            jsb.pushString("false");
        end
        JSON_TRUE: begin
            jsb.pushString("true");
        end
        JSON_NUMBER: begin
            string str;
            str.realtoa(this_number);
            jsb.pushString(str);
        end
        JSON_STRING: begin
            jsb.pushRawString(this_string);
        end
        JSON_ARRAY: begin
            jsb.pushString("[");
            foreach(this_array[i]) begin
                jsb.addIndents(this_depth+1);
                ret = this_array[i].toString(jsb);
                if (ret != STRINGIFY_OK) begin
                    return ret;
                end
                if (i != this_array.size() -1) begin
                    jsb.pushString(", ");
                end
            end
            jsb.addIndents(this_depth);
            jsb.pushString("]");
        end
        JSON_OBJECT: begin
            string str;
            string key;
            int idx = 0;
            //string k;
            jsb.pushString("{");
            /*
            *
            if (this_object.first(key)) begin
                do begin
                    jsb.pushString("\"");
                    jsb.pushRawString(key);
                    jsb.pushString("\"");
                    jsb.pushString(": ");
                    ret = this_object[key].toString(jsb);
                    if (ret != STRINGIFY_OK) begin
                        return ret;
                    end
                    if (!this_object.last(key)) begin
                        jsb.pushString(", ");
                    end else begin
                        `JSON_LOG($sformatf("Last key: %s", key))
                    end
                end while (this_object.next(key));
            end
            * */
            foreach(this_object[key]) begin
                idx++;
                jsb.addIndents(this_depth+1);
                jsb.pushRawString(key);
                jsb.pushString(": ");
                ret = this_object[key].toString(jsb);
                if (ret != STRINGIFY_OK) begin
                    return ret;
                end
                if (idx < this_object.size()) begin
                    jsb.pushString(", ");
                end
            end
            jsb.addIndents(this_depth);
            jsb.pushString("}");
        end
        default: begin
            return VALUE_TYPE_ERROR;
        end
    endcase
    return ret;
endfunction

function JSONStatus JSONValue::dumpToFile (
    string json_file,
    int unsigned indent = 0
);
    string json_txt;
    JSONStatus ret;
    int jfd;
    jfd = $fopen(json_file, "w");
    if (jfd == 0) begin
        return FILE_OPEN_ERROR;
    end
    ret = dumps(json_txt, indent);
    $fdisplay(jfd, "%s", json_txt);
    $fclose(jfd);
    return ret;
endfunction

