# JSONinSV

![](https://img.shields.io/badge/license-MIT-green)

JSON lib in Systemverilog

- [简介](#简介)
- [Reference](#reference)
- [规格介绍](#规格介绍)
    - [性能考虑](#性能考虑)
- [API说明](#api说明)
    - [枚举常数](#枚举常数)
    - [用户函数](#用户函数)
- [使用介绍](#使用介绍) 
    - [JSON库使用](#json库使用) 
    - [测试用例运行](#测试用例运行) 
    - [仿真器适配](#仿真器适配情况) 


## 简介

JSON是应用广泛的一种数据表示格式, 常用于进程间复杂数据的交互. 

多年以前我在网络上发现了某前辈发布的JSON教程, 开始接触到JSON, 后面陆续开始基于JSON开发了一些小规模工具. 作为一名验证工程师, 将验证平台真正的加入到JSON生态中, 是很久远的一个想法了, 这是JSONinSV这个项目的由来.

这个项目的目的是提供SystemVerilog实现的JSON解析库和生成库, 实现和外围组件的更有目的性的互动, 帮助使用者开发出更灵活更强大的验证应用.

此外, 本项目还提供了JSON库的单元测试, 后续可考虑将这里的单元测试框架独立出来进行项目上的应用.

## Reference

1. [ECMA-404](https://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf)
1. [RFC-8259](https://www.rfc-editor.org/rfc/rfc8259.txt)
1. [json-tutorial](https://github.com/miloyip/json-tutorial)
1. IEEE1800-IEEE Standard for SystemVerilog

## 规格介绍

JSONinSV实现的功能规格主要是三个部分:

1. JSON文本的解析, 包括从字符串解析和文本文件解析;
2. JSON文本输出, 支持JSON顶层值输出到格式化字符串以及输出到文本文件;
3. 支持JSON值的编辑;

对应JSON的值类型, JSONinSV的实现规格如下:

1. `true, false, null`只支持直接对应的小写字面值;
2. 字符串. 理论上支持任意编码格式的字符串, 但是为了EDA工具的兼容性, 用户应当尽量使用纯ASCII字符集. 结合IEEE1800 5.9节以及RFC8259的第9章, JSONinSV支持的转义字符有:
```
"\""
"\\"
"\n"
"\t"
"\f"
```
3. 数字统一解析为SystemVerilog中的real类型, 即IEEE574定义的64bit双精度浮点数. 需要支持大整数和高精度数据等超过64bit双精度浮点数表示的数据时, 建议用户使用字符串表示数值并在上层应用中实现.
4. 列表, 支持空列表.
5. 对象, 支持空对象. 对于key重复的值, 会使用后面的key-value成员进行覆盖. **需要注意的是, JSONinSV目前直接使用SystemVerilog的联合数组实现对象, 因此JSON文本中的对象成员会经过key排序存放, 不能保证存放顺序与JSON文本中成员一致.**

文本输出和对象编辑器部分, 支持如下规格:

1. 支持格式化输出, 并支持配置indent进行层级化排版输出;
2. 支持复合节点的回环检查;

### 性能考虑

验证平台中的JSON应用, 按照我的经验, 主要是环境配置以及可能的transaction级别的数据交互. 总体说来, 验证平台中的JSON库是性能不敏感的.

如出现需要验证平台与外围进程进行高实时性的JSON交互, 需要评估好仿真器上的JSON库开销, 可能需要借助DPI-C和C语言实现的JSON库进行应用部署.

## API说明

SVinJSON提供面向对象形式的API, 实现在`JSONValue`类型中.

### 枚举常数

用户需要使用的枚举常数包括JSON类型枚举和返回值枚举.

其中类型枚举`JSONType`用于指示JSON节点的类型, 其定义如下:

枚举值 | 含义
--|--
JSON\_OBJECT | 对象
JSON\_ARRAY  | 数组
JSON\_STRING | 字符串
JSON\_NUMBER | 数值
JSON\_TRUE   | 真值
JSON\_FALSE  | 伪值
JSON\_NULL   | 空值

返回值枚举`JSONStatus`定义如下:

枚举值 | 含义
--|--
PARSE\_OK| 解析正确
PARSE\_NO\_VALUE| JSON文本中没有值
PARSE\_ROOT\_NOT\_SINGULAR| JSON文本中存在多个顶层
PARSE\_INVALID\_VALUE| 错误的值节点, 包括空值, 伪值, 真值, 数值, 字符串中的文本错误
PARSE\_MISS\_KEY| 对象中缺少Key字符串
PARSE\_MISS\_COLON| 对象成员间缺少分号
PARSE\_MISS\_COMMA\_OR\_CURLY\_BRACKET| 对象中缺少逗号或花括号
PARSE\_MISS\_QUOTATION\_MARK| 缺少引号
PARSE\_MISS\_COMMA\_OR\_SQUARE\_BRACKET| 数组中缺少逗号或方括号
FILE\_OPEN\_ERROR| 文件打开失败
DUMP\_OK| JSON输出成功
STRINGIFY\_OK| JSON值字符串化成功
CHECK\_OK| JSON值检查成功
CHECK\_DEPTH\_ERROR| JSON值层级检查失败

### 用户函数

构造函数:

原型定义 | 说明
--|--
`JSONValue new(int depth = 0)` | 参数depth用于指定当前JSON value的层次, 默认值0表示为根节点值. 在JSON解析应用时, 用户使用默认值即可. 在使用编辑模式时, 用户需要维护好JSON value的层次信息.

顶层应用函数:

原型定义 | 说明
--|--
`JSONStatus loads(string json_txt)` | 根据参数`json_txt`指定的JSON文本进行解析
`JSONStatus loadFromFile(string json_file)` | 根据参数`json_file`指定的文本文件进行JSON文本解析
`JSONStatus dumps(ref string json_txt, int indent=0)` | 将JSONValue输出到字符串`json_txt`中, indent表示缩进字符数量, 在indent不为0时会进行换行排版, 并使用indent根据JSONValue的节点层次进行缩进
`JSONStatus dumpToFile(string json_file, int indent=0)` | 将JSONValue输出到`json_file`指定的文件中, indent表示缩进字符数量, 在indent不为0时会进行换行排版, 并使用indent根据JSONValue的节点层次进行缩进

setter和getter函数:

原型定义 | 说明
--|--
`JSONType getType()` | 获取当前JSONValue的枚举值
`string getTypeString()` | 获取当前JSONValue的枚举值字符串
`real getNumber ()` | 获取当前JSONValue的浮点数值, 如果当前类型不匹配会输出错误信息
`string getString ()` | 获取当前JSONValue的字符串, 如果当前类型不匹配会输出错误信息
`int getArraySize ()` | 获取当前JSONValue的数组深度, 如果当前类型不匹配会输出错误信息
`JSONValue getArrayElement (int idx)` | 根据索引`idx`获取当前JSONValue的数组成员, 如果当前类型不匹配会输出错误信息
`int getObjectSize ()` | 获取当前JSONValue的数组深度, 如果当前类型不匹配会输出错误信息
`JSONValue getObjectMember (string key)` | 根据`key`键信息获取当前JSONValue的对象成员值, 如果当前类型不匹配会输出错误信息
`void setNull()` | 设置当前JSONValue节点为`null`
`void setTrue()` | 设置当前JSONValue节点为`true`
`void setFalse()` | 设置当前JSONValue节点为`false`
`void setNumber(real number)` | 根据`number`的值设置当前JSONValue节点为数值
`void setString(string str)` | 根据参数`str`设置当前JSONValue节点为字符串
`void setObject()` | 设置当前JSONValue节点为对象
`void addMemberToObject(string key, JSONValue val)` | 在当前JSONValue的对象中根据`key-value`添加成员, 如果当前类型不匹配会输出错误信息
`void setArray()` | 设置当前JSONValue节点为数组
`void addValueToArray(JSONValue val)` | 在当前JSONValue的数组中添加`val`成员, 如果当前类型不匹配会输出错误信息

子成员创建函数, 用于创建符合层级约束的`JSON_ARRAY`和`JSON_OBJECT`节点成员:

原型定义 | 说明
--|--
`JSONValue createMemberOfObject(string key, JSONType jtype = JSON_NULL)` | 创建`JSON_OBJECT`节点的成员, 使用参数`key`作为索引, 使用`jtype`作为成员节点的类型, 需要注意如果是`JSON_STRING`和`JSON_NUMBER`类型, 会使用默认值进行值set, 会需要在创建后另外调用setter函数进行值配置
`JSONValue createValueOfArray(JSONType jtype = JSON_NULL)` | 创建`JSON_ARRAY`节点的成员, 使用`jtype`作为成员节点的类型, 需要注意如果是`JSON_STRING`和`JSON_NUMBER`类型, 会使用默认值进行值set, 会需要在创建后另外调用setter函数进行值配置

成员删除函数:

原型定义 | 说明
--|--
`void removeMemberOfObject(string key)` | 根据`key`删除本对象节点的对应成员
`void removeValueOfArray(int unsigned idx)` | 根据`idx`删除本数组节点的对应JSON值

## 使用说明

### JSON库使用

编译时添加`json_pkg`并添加`json_pkg`所在的路径到include路径到搜索路径:

```
$(EDA_COMPILER) $(JSON_PKG_DIR)/json_pkg +incdir+$(JSON_PKG_DIR) ..other_options
```

使用示例如下:

```
JSONValue jv;
jv = new();
jv.loads(
{
" { ",
"\"n\" : null , ",
"\"f\" : false , ",
"\"t\" : true , ", 
"\"i\" : 123 , ",
"\"s\" : \"abc\", ",
"\"a\" : [ 1, 2, 3 ],",
"\"o\" : { \"1\" : 1, \"2\" : 2, \"3\" : 3 }",
" } "
);

assert(7, jv.getObjectSize()); // get 7 members in object
assert(JSONValue::JSON_NULL, jv.getObjectMember("n").getType()); // get null with key "n"
assert(JSONValue::JSON_FALSE, jv.getObjectMember("f").getType()); // get false with key "f"
assert(JSONValue::JSON_TRUE, jv.getObjectMember("t").getType()); // get true with key "t"
assert(JSONValue::JSON_NUMBER, jv.getObjectMember("i").getType()); // get number with key "i"
assert(JSONValue::JSON_STRING, jv.getObjectMember("s").getType()); // get string with key "s"
assert(JSONValue::JSON_ARRAY, jv.getObjectMember("a").getType()); // get array with key "a"
assert(JSONValue::JSON_OBJECT, jv.getObjectMember("o").getType()); // get object with key "o"
```

### 测试用例运行

`test`目录下是完整的测试环境和测试用例, 用户可以使用:

```
$(EDA_COMPILER) $(JSON_PKG_DIR)/json_pkg +incdir+$(JSON_PKG_DIR) \
                $(JSON_PKG_DIR)/test_factory/test_pkg.sv +incdir+$(JSON_PKG_DIR)/test_factory \
                $(JSON_PKG_DIR)/top.sv \
                ..other_options
```

然后使用如下命令:

```
$(EDA_SIM_CMD) +TEST=[test_name]
```

进行用例运行展示, 目前支持的用例如下:

```
Please offer a +TEST=<test_name> in simulation arguments
Tests available: 
   json_array_test
   json_literal_test
   json_number_test
   json_object_test
   json_string_test
   json_file_test
   json_error_test
   json_loop_test
```

其中`json_literal_test`包括`null`, `false`和`true`的解析测试.

在运行`json_file_test`时, 默认使用`..`从仿真目录指向`test`目录, 在仿真目录层级有差异时使用:

```
$(EDA_SIM_CMD) +TEST=json_file_test +DIR=[rel_path]
```

`+DIR=`参数进行运行时调整.

此外, 使用`+TEST=test_all`可以连续运行所有用例.

### 仿真器适配情况

JSONinSV在S/C/M三家的仿真器上都经过测试, 目前S/M的仿真器适配良好, 而C的仿真器存在如下问题:

1. 不支持指数形式的浮点数字符串文本转换;
2. 不支持浮点数字符串格式化;

其中[1]会影响JSONinSV的使用, [2]会影响定义的number测试结果(指数形式转换测试). 由于目前未计划实现字符串文本转浮点数(当前版本使用SystemVerilog中`string`的内置`atoreal`方法实现), 需要在C仿真器中使用JSONinSV的用户需要注意避免使用指数形式的浮点表示.

在实现完JSONinSV的文本输出功能之后, 发现三家仿真器均存在`realtoa`浮点数精度丢失的问题, 用户可在编译时添加`+USE_REALTOA`, 使用`json_loop_test`测试用例进行确认. 目前使用的字符串格式化方案进行浮点转换后是没有这个问题的.

