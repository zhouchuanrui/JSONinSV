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

多年以前我在网络上发现了某前辈发布的JSON教程, 开始接触到JSON, 后面陆续开始基于JSON开发了一些小规模工具. 作为一名验证工程师, 将验证平台真正的加入到JSON生态中, 是很久远的一个想法了, 这便是JSONinSV这个项目的由来.

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
5. 对象, 支持空对象. 对于key重复的值, 会使用后面的key-value成员进行覆盖.

文本输出和对象编辑器部分, 支持如下规格:

1. 支持格式化输出, 并支持配置indent;
2. 支持复合节点的回环检查;

### 性能考虑

验证平台中的JSON应用, 按照我的经验, 主要是环境配置以及可能的transaction级别的数据交互. 总体说来, 验证平台中的JSON库是性能不敏感的.

如出现需要验证平台与外围进程进行高实时性的JSON交互, 需要评估好仿真器上的JSON库开销, 可能需要借助DPI-C和C语言实现的JSON库进行应用部署.

## API说明

### 枚举常数

用户需要使用的枚举常数包括JSON类型枚举和返回值枚举.

其中类型枚举用于指示JSON节点的类型, 其定义如下:

枚举值 | 含义
--|--
JSON\_OBJECT | 对象
JSON\_ARRAY  | 数组
JSON\_STRING | 字符串
JSON\_NUMBER | 数值
JSON\_TRUE   | 真值
JSON\_FALSE  | 伪值
JSON\_NULL   | 空值

返回值枚举定义如下:

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

### 用户函数

构造函数:

原型定义 | 说明
--|--
`new(int depth = 0)` | 

## 使用说明

### JSON库使用

### 测试用例运行

### 仿真器适配情况

JSONinSV在S/C/M三家的仿真器上都经过测试, 目前S/M的仿真器适配良好, 而C的仿真器存在如下问题:

1. 不支持指数形式的浮点数字符串文本转换;
2. 不支持浮点数字符串格式化;

其中[1]会影响JSONinSV的使用, [2]会影响定义的number测试结果(指数形式转换测试). 由于目前未计划实现字符串文本转浮点数(当前版本使用SystemVerilog中`string`的内置`atoreal`方法实现), 需要在C仿真器中使用JSONinSV的用户需要注意避免使用指数形式的浮点表示.

