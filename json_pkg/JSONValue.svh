//
//File: JSONValue.svh
//Device: 
//Author: zhouchuanrui@foxmail.com
//Created:  2021/1/26 7:36:07
//Description: JSON value
//Revisions: 
//2021/1/26 7:36:46: created
//

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

    // JSON status enumerate
    typedef enum {
        PARSE_OK = 0,
        PARSE_INVALID_VALUE,
        PARSE_MISS_QUOTATION_MARK
    } JSONStatus;

    function new(depth = 0, );
        this_type = JSON_NULL;
        this_depth = 0;
    endfunction

    protected JSONValue this_object[string];
    protected JSONValue this_array[$];
    protected string this_string;
    protected real this_number;

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

endclass: JSONValue

