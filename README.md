# JSONinSV
JSON lib in Systemverilog

## 简介

JSON是应用广泛的一种数据表示格式, JSONinSV是使用SystemVerilog实现的JSON库. 

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

## API说明

## 使用示例

