#import "template.typ": report, exp-title, exp-section, three-line-table, exp-chapter

#let exp1 = "实验3：用Lex设计词法分析器1"
#let exp2 = "实验4：使用Lex设计词法分析器2"


#show: report.with(
  title: "编译原理实验报告",
  experiments: (exp1, exp2),
  members: (("AA", "zzzzxxxx"),("VVV","zzzzxxxx"),("BBB","zzzzxxxx"),("CCC","zzzzxxxx")),
  date: "2026年5月16日",
)

// ============================================================
//  实验1
// ============================================================

#exp-title(exp1)

#exp-section(1, "实验目的")

学会用lex设计一个词法分析器。

#exp-section(2, "实验内容")
使用lex为下述文法语言写一个词法分析器。

语言文法：
```lex
<程序> → PROGRAM <标识符> ; <分程序>
<分程序> → <变量说明> BEGIN <语句表> END.
<变量说明> → VAR <变量说明表>;
<变量说明表> → <变量表>: <类型> | <变量表>: <类型>; <变量说明表>
<类型> → INTEGER | REAL
<变量表> → <变量> | <变量>, <变量表>
<语句表> → <语句> | <语句>; <语句表>
<语句> → <赋值语句> | <条件语句> | <WHILE语句> | <复合语句>
<赋值语句> → <变量> := <算术表达式>
<条件语句> → IF <关系表达式> THEN <语句> ELSE <语句>
<WHILE语句> → WHILE <关系表达式> DO <语句>
<复合语句> → BEGIN <语句表> END
<算术表达式> → <项> | <算术表达式> + <项> | <算术表达式> - <项>
<项>  → <因式> | <项> * <因式> | <项> / <因式>
<因式> → <变量> | <常数> | (<算术表达式>)
<关系表达式> → <算术表达式> <关系符> <算术表达式>
<变量> → <标识符>
<标识符> → <标识符><字母> | <标识符><数字> | <字母>
<常数> → <整数> | <浮点数>
<整数> → <数字> | <数字> <整数>
<浮点数> → .<整数> | <整数>.<整数>
<关系符> → < | <= | = | > | >= | <>
<字母> → A | B | …| X | Y | Z | a | b | …| x | y | z
<数字> → 0|1|2|…|9
```
#exp-section(3, "实验要求")

在已有代码基础上补充圆括号的识别逻辑，使词法分析器能够正确输出 `BRACKETS` 记号。

#exp-section(4, "实验过程及重点内容")

本实验涉及的记号类型如 @tab:token-types2 所示。

#figure(
  three-line-table(
    columns: 3,
    [`记号类型`], [`匹配规则`], [`示例`],
    
[`PROGRAM`], [`"PROGRAM"`], [`PROGRAM`],
    [`VAR`], [`"VAR"`], [`VAR`],
    [`BEGIN`], [`"BEGIN"`], [`BEGIN`],
    [`END`], [`"END"`], [`END`],
    [`INTEGER`], [`"INTEGER"`], [`INTEGER`],
    [`REAL`], [`"REAL"`], [`REAL`],
    [`IF`], [`"IF"`], [`IF`],
    [`THEN`], [`"THEN"`], [`THEN`],
    [`ELSE`], [`"ELSE"`], [`ELSE`],

    [`INT`], [`[0-9]+`], [`123`],
    [`FLOAT`], [`"."[0-9]+ | [0-9]+"."[0-9]+`], [`.5` 或 `12.34`],

    [`SEMICOLON`], [`";"`], [`;`],
    [`COLON`], [`":"`], [`:`],
    [`COMMA`], [`","`], [`,`],
    [`ASSIGN`], [`":="`], [`:=`],
    [`PERIOD`], [`"."`], [`.`],

    [`PLUS`], [`"+"`], [`+`],
    [`MINUS`], [`"-"`], [`-`],
    [`TIMES`], [`"*"`], [`*`],
    [`DIVIDE`], [`"/"`], [`/`],

    [`LPAREN`], [`"("`], [`(`],
    [`RPAREN`], [`")"`], [`)`],
  ),
  caption: [实验3涉及的记号类型],
) <tab:token-types2>

*1. 添加记号类型定义*

在定义区添加宏定义：

```c
/* 保留字宏定义 */
#define PROGRAM   1
#define VAR       2
#define BEGINING     3
#define END       4
#define INTEGER   5
#define REAL      6
#define IF        7
#define THEN      8
#define ELSE      9
#define WHILE     10
#define DO        11

/* 标识符与常量 */
#define ID        12
#define INT       13
#define FLOAT     14

/* 界符与算术运算符 */
#define SEMICOLON 15
#define COLON     16
#define COMMA     17
#define ASSIGN    18
#define PERIOD    19
#define PLUS      20
#define MINUS     21
#define TIMES     22
#define DIVIDE    23
#define LPAREN    24
#define RPAREN    25

/* 关系运算符*/
#define LT        26
#define LE        27
#define GT        28
#define GE        29
#define EQ        30
#define NE        31

/* 辅助与错误控制 */
#define NEWLINE     32
#define ERRORCHAR   33
```
我们在原始词法分析程序的基础上，按照题目要求对记号类型定义部分进行了扩展，补充定义了程序关键字、变量声明关键字、类型关键字、条件语句关键字、常量、界符以及算术运算符等记号类型。

首先，新增了 PROGRAM、VAR、BEGINING、END、INTEGER、REAL、IF、THEN、ELSE 等保留字记号。其中 BEGINING 用于表示源程序中的 BEGIN 关键字，这是因为 BEGIN 在 Lex/Flex 中是用于状态切换的系统宏，不能直接作为普通记号宏名使用。

其次，原程序中只使用 NUMBER 表示所有数字常量，我们将数字常量进一步细分为 INT 和 FLOAT，分别用于表示整数常量和浮点常量，使词法分析器能够更准确地区分不同类型的常量。

再次，新增了 SEMICOLON、COLON、COMMA、ASSIGN、PERIOD、LPAREN、RPAREN 等界符记号，用于识别分号、冒号、逗号、赋值符、句点以及左右括号等符号。

最后，新增了 PLUS、MINUS、TIMES、DIVIDE 四个算术运算符记号，用于识别表达式中的加、减、乘、除运算符。通过这些记号类型的补充，词法分析器能够覆盖实验文法中出现的大部分终结符，为后续语法分析提供更完整的记号序列。

*2. 整数常量和浮点常量的正规定义*

```
inconst   {digit}+
floaconst (\.{digit}+)|({digit}+\.{digit}+)
```

*3. 添加界符符号的识别规则*

```lex
<INITIAL>":="       { return ASSIGN; }
<INITIAL>":"        { return COLON; }
<INITIAL>";"        { return SEMICOLON; }
<INITIAL>","        { return COMMA; }
<INITIAL>"."        { return PERIOD; }
<INITIAL>"("        { return LPAREN; }
<INITIAL>")"        { return RPAREN; }
```


*4. 添加算数运算符的识别规则*

```lex
<INITIAL>"+"        { return PLUS; }
<INITIAL>"-"        { return MINUS; }
<INITIAL>"*"        { return TIMES; }
<INITIAL>"/"        { return DIVIDE; }
```

*5. 保留字识别规则*
```lex
<INITIAL>"PROGRAM"  { return PROGRAM; }
<INITIAL>"VAR"      { return VAR; }
<INITIAL>"BEGIN"    { return BEGINING; }
<INITIAL>"END"      { return END; }
<INITIAL>"INTEGER"  { return INTEGER; }
<INITIAL>"REAL"     { return REAL; }
<INITIAL>"IF"       { return IF; }
<INITIAL>"THEN"     { return THEN; }
<INITIAL>"ELSE"     { return ELSE; }
<INITIAL>"WHILE"    { return WHILE; }
<INITIAL>"DO"       { return DO; }
```

*6. 拓展`writeout`输出函数*

我们定义了这么多的拓展文法所以需要增加`case`分支,使程序能把新识别出的记号输出成二元组形式。保证新 token 不仅能被识别，还能被正确输出。
```c
void writeout(int c) {
  switch(c) {
    case PROGRAM:   fprintf(yyout, "(PROGRAM, \"%s\") ", yytext); break;
    case VAR:       fprintf(yyout, "(VAR, \"%s\") ", yytext); break;
    case BEGINING:     fprintf(yyout, "(BEGIN, \"%s\") ", yytext); break;
    case END:       fprintf(yyout, "(END, \"%s\") ", yytext); break;
    case INTEGER:   fprintf(yyout, "(INTEGER, \"%s\") ", yytext); break;
    case REAL:      fprintf(yyout, "(REAL, \"%s\") ", yytext); break;
    case IF:        fprintf(yyout, "(IF, \"%s\") ", yytext); break;
    case THEN:      fprintf(yyout, "(THEN, \"%s\") ", yytext); break;
    case ELSE:      fprintf(yyout, "(ELSE, \"%s\") ", yytext); break;
    case WHILE:     fprintf(yyout, "(WHILE, \"%s\") ", yytext); break;
    case DO:        fprintf(yyout, "(DO, \"%s\") ", yytext); break;
    case ID:        fprintf(yyout, "(ID, \"%s\") ", yytext); break;
    case INT:       fprintf(yyout, "(INT, \"%s\") ", yytext); break;
    case FLOAT:     fprintf(yyout, "(FLOAT, \"%s\") ", yytext); break;
    case SEMICOLON: fprintf(yyout, "(SEMICOLON, \"%s\") ", yytext); break;
    case COLON:     fprintf(yyout, "(COLON, \"%s\") ", yytext); break;
    case COMMA:     fprintf(yyout, "(COMMA, \"%s\") ", yytext); break;
    case ASSIGN:    fprintf(yyout, "(ASSIGN, \"%s\") ", yytext); break;
    case PERIOD:    fprintf(yyout, "(PERIOD, \"%s\") ", yytext); break;
    case PLUS:      fprintf(yyout, "(PLUS, \"%s\") ", yytext); break;
    case MINUS:     fprintf(yyout, "(MINUS, \"%s\") ", yytext); break;
    case TIMES:     fprintf(yyout, "(TIMES, \"%s\") ", yytext); break;
    case DIVIDE:    fprintf(yyout, "(DIVIDE, \"%s\") ", yytext); break;
    case LPAREN:    fprintf(yyout, "(LPAREN, \"%s\") ", yytext); break;
    case RPAREN:    fprintf(yyout, "(RPAREN, \"%s\") ", yytext); break;
    case LT:        fprintf(yyout, "(LT, \"%s\") ", yytext); break;
    case LE:        fprintf(yyout, "(LE, \"%s\") ", yytext); break;
    case GT:        fprintf(yyout, "(GT, \"%s\") ", yytext); break;
    case GE:        fprintf(yyout, "(GE, \"%s\") ", yytext); break;
    case EQ:        fprintf(yyout, "(EQ, \"%s\") ", yytext); break;
    case NE:        fprintf(yyout, "(NE, \"%s\") ", yytext); break;
    case ERRORCHAR:   fprintf(yyout, "(ERRORCHAR, \"%s\") ", yytext); break;
    case NEWLINE:     fprintf(yyout, "\n"); break;
    default: break;
  }
  return;
}
```

*7. 细化了关系运算符*
在原始代码中虽然定义了
```c
#define LT 1
#define LE 2
#define GT 3
#define GE 4
#define EQ 5
#define NE 6
```
但是在处理的时候都是统一返回RELOP
```c
<INITIAL>"<"   {return (RELOP);}
<INITIAL>"<="  {return (RELOP);}
```
我们必须得对这个进行处理和细分
```c
<INITIAL>"<="       { return LE; }
<INITIAL>">="       { return GE; }
<INITIAL>"<>"       { return NE; }
<INITIAL>"<"        { return LT; }
<INITIAL>">"        { return GT; }
<INITIAL>"="        { return EQ; }
```

#exp-section(5, "实验结果")

#figure(
  image("image/实验3实验结果.png"),
  caption: [实验3实验结果]
)

#exp-section(6, "实验中遇到的问题、难点及解决方案")

*1. 为什么不声明称BEGIN变量而是声明称BEGINING变量*

答：因为 BEGIN 在 Lex/Flex 中是用于状态切换的系统宏，不能直接作为普通记号宏名使用

\
\
\
*2. parser0.y文件的作用是什么？*

parser0.y 是一个 Yacc/Bison 语法分析器描述文件，用于定义源语言的终结符、属性值类型以及语法产生式。它的主要作用是接收 Lex 词法分析器返回的记号序列，并根据文件中给出的文法规则判断该记号序列是否构成合法的程序结构。

在该文件中，%token 部分定义了语法分析过程中可能出现的终结符，例如 PROGRAM、ID、SEMICOLON、VAR、INTEGER、BEGINN、END、ASSIGN、INT 等。这些终结符应当与 Lex 文件中返回的记号类型保持一致。因此，在本次词法分析实验中，parser0.y 可以作为确定需要识别哪些终结符的参考。

%union 部分定义了记号属性值可能使用的数据类型，例如 ID 对应字符串属性，INT 对应整数属性，FLOAT 对应浮点数属性。后续若将词法分析器与语法分析器连接使用，词法分析器不仅需要返回记号类型，还需要通过 yylval 将标识符名、整数值、浮点数值等属性传递给语法分析器。

文法规则部分以 program 为开始符号，定义了一个简单程序的基本结构，即 PROGRAM ID ; VAR ID : INTEGER ; BEGIN ID := INT END .。因此，parser0.y 的核心作用是描述语言的语法结构，并为后续语法分析实验提供基础框架。

#exp-section(7, "实验感想与收获")

通过本次实验，我进一步熟悉了使用 Lex 编写词法分析器的基本方法。相比之前的实验，本次实验的难度并没有明显增加，核心仍然是根据文法中的终结符编写对应的正规定义和匹配规则。但是，本次实验需要添加的记号类型较多，包括保留字、常量、界符、算术运算符和关系运算符等，因此整体任务量比之前更大，对代码的完整性要求也更高。

实验过程中比较重要的一个问题是 `BEGIN` 的命名冲突。由于 `BEGIN` 在 Lex/Flex 中本身是用于状态切换的宏，不能直接作为普通记号名使用，因此我在代码中使用 `BEGINING` 来表示源程序中的 `BEGIN` 关键字。这个问题让我认识到，编写词法分析器时不仅要考虑源语言的文法，还要注意 Lex/Flex 工具本身的保留名称和使用规则。

此外，我也了解了 `parser0.y` 文件的作用。它是 Yacc/Bison 的语法分析器描述文件，主要用于接收词法分析器返回的记号序列，并根据文法规则判断程序结构是否合法。通过本次实验，我对词法分析和语法分析之间的关系有了更清楚的理解，也为后续将 Lex 与 Yacc/Bison 结合使用打下了基础。



// ============================================================
//  实验2
// ============================================================

\
\
\


#exp-title(exp2)

#exp-section(1, "实验目的")

本次实验的目的是在上一次实验 3 词法分析器的基础上继续进行修改，进一步学习如何使用 Lex/Flex 设计词法分析器，并重点理解词法分析器与后续语法分析器之间的连接方式。
通过本次实验，需要掌握 `yylex` 函数每次只返回一个记号 `token` 的工作方式，并理解词法分析器在返回记号类型的同时，如何通过全局变量 `yylval` 保存该记号对应的属性值。由于不同记号的属性类型不同，例如标识符对应字符串，整数对应整型数值，浮点数对应浮点数值，因此本实验还需要掌握 `union` 类型在保存多种属性值时的使用方法。


#exp-section(2, "实验内容")

本次实验是在实验 3 已完成的词法分析器基础上进行修改，使其不仅能够识别简单语言中的各类记号，还能够为部分记号设置合适的属性值，并在每次 `yylex` 返回记号之前，将该记号的属性值存入全局变量 `yylval` 中。
具体来说，词法分析器需要识别的记号包括关键字、标识符、整数、浮点数、类型名、分隔符、赋值符号、关系运算符以及算术运算符等。对于 `PROGRAM`、`VAR`、`BEGIN`、`END`、`INTEGER`、`REAL`、`IF`、`WHILE`、`DO`、`THEN`、`ELSE` 等关键字，程序只需要返回相应的记号类型即可，属性值可以省略或直接使用 `yytext` 输出。对于标识符、整数和浮点数，则必须分别将标识符字符串、整数值和浮点数值保存到 `yylval` 中，并在 `writeout` 函数中使用 `yylval` 的值进行输出。


#exp-section(3, "实验要求")

+ 要求每次调用词法分析函数yylex时，只返回一个记号(token)。
+ 为记号选择适当的属性值，并且每次词法分析函数返回记号前，都将记号的属性值存入全局变量yylval中。（yylval可以自己定义为全局变量）。
+ 记号属性值的选择：标识符的属性为标识符的名字字符串（例如，标识符name1的属性为字符串”name1”），整数的属性为整数值，浮点数的属性为浮点数值。其他记号属性值可自己选择。关键字可以省略属性。
+ 打印记号属性值时，对于标识符、整数和浮点数使用yylval的值作为属性值进行打印（即在writeout函数中，对于标识符、整数和浮点数的属性值使用yylval的值替换yytext）。
+ 注意：由于属性值需要存入yylval中，并且记号属性值的类型比较多（可能为字符串、整数、浮点数等），因此yylval必须能同时存放各种类型的值（提示：将yylval设置为union类型）。

#exp-section(4, "实验过程及重点内容")

*1. 修改记号类型定义 *

在实验 3 的基础上，本次实验继续保留对简单语言各类终结符的识别，同时对记号编号进行了调整。代码中定义了标识符、整数、浮点数、类型名、分隔符、关键字、赋值与关系运算符、算术运算符、换行控制以及错误字符等记号。

本实验相比实验三（@tab:token-types2）所增加的记号类型如表 @tab:token-types 所示

#figure(
  three-line-table(
    columns: 3,
    [`记号类型`], [`匹配规则`], [`示例`],
    
    [`ID`], [`[A-Za-z][A-Za-z0-9]*`], [`abc`],

    [`WHILE`], [`"WHILE"`], [`WHILE`],
    [`DO`], [`"DO"`], [`DO`],

    [`EQ`], [`"="`], [`=`],
    [`NEQ`], [`"<>"`], [`<>`],
    [`LT`], [`"<"`], [`<`],
    [`LE`], [`"<="`], [`<=`],
    [`GT`], [`">"`], [`>`],
    [`GE`], [`">="`], [`>=`],
  ),
  caption: [实验4相较实验3新增的记号类型],
) <tab:token-types>


其中，BEGIN 由于在 Lex/Flex 中本身是一个用于状态切换的宏，不能直接作为普通 token 名使用，因此代码中使用 BEGINN 表示源程序中的 BEGIN 关键字。在输出时，再将其打印为 BEGIN。


*2. 使用 union 定义 设计 token 属性值的保存方式*

本次实验最核心的修改是将 yylval 从单一的 int 类型修改为 union 类型。因为在词法分析过程中，不同记号的属性值类型不同：标识符需要保存字符串，整数需要保存 int 类型数值，浮点数需要保存 double 类型数值。如果仍然使用 int 类型，就无法同时满足这些属性值的保存需求。

因此代码中定义了如下 union 类型：



```c
typedef union{
  int intval;
  float floatval;
  char* sval;
}
```

其中，ival 用于保存整数属性值，fval 用于保存浮点数属性值，sval 用于保存标识符字符串属性值。这样，词法分析器在识别到不同类型的记号时，就可以根据记号类型选择 yylval 中对应的成员保存属性值。例如，识别整数时使用 yylval.ival，识别浮点数时使用 yylval.fval，识别标识符时使用 yylval.sval。这种设计也更接近 Lex 与 Yacc/Bison 结合时传递语义属性的实际方式。

这里不能直接让 yylval.sval 指向 yytext。因为 yytext 是 Lex/Flex 内部维护的当前匹配缓冲区，每次继续扫描新的 token 时，yytext 的内容都可能发生变化。如果直接保存 yytext 的地址，后续匹配可能会覆盖原来的标识符内容。

为了解决这个问题，程序定义了 copy_string 函数，如图二所示。该函数使用 malloc 为字符串重新分配空间，并将 yytext 中的内容复制到新的内存中。这样，即使后续 yytext 内容发生变化，已经保存到 yylval.sval 中的标识符属性值也不会受到影响。

```c
char *copy_string(const char *s) {
    char *p = (char *)malloc(strlen(s) + 1);
    if (p == NULL) {
        fprintf(stderr, "malloc failed\n");
        exit(1);
    }
    strcpy(p, s);
    return p;
}
```

* 3. 编写 Lex 规则并在规则动作中返回 token *

在 Lex 文件的定义区中，程序首先对常用字符模式进行正规定义，包括空白符、字母、数字、标识符、整数和浮点数等。这样可以让后续规则区更加清晰。主要正规定义如下：

- 	delim 用于匹配空格、制表符、回车和换行。
- 	ws 表示一个或多个空白符。
- 	letter 表示字母。
- 	digit 表示数字。
- 	id 表示标识符，其规则为以字母开头，后面可以跟字母或数字。
- 	integer 表示整数，其规则为一个或多个数字。
- 	float 表示浮点数，其规则相对复杂，既支持普通小数形式，也支持指数形式。

本实验中的浮点数规则能够识别多种情况，例如 2.13、2.、.49、12.3E5、.5E-2 和 12E3 等。程序将整数和浮点数拆分为不同规则，如下所示

```bison
integer     {digit}+
float       (({digit}+\.{digit}*)|(\.{digit}+))([Ee][+-]?{digit}+)?|({digit}+[Ee][+-]?{digit}+)

```
在规则书写顺序上，需要注意以下几点。

首先，关键字规则必须写在标识符规则之前。因为 Lex/Flex 采用最长匹配原则，在匹配长度相同的情况下，会优先选择规则区中靠前的规则。如果把 id 规则写在关键字规则之前，那么 PROGRAM、VAR、BEGIN 等关键字就会被识别成普通标识符 ID。

如下图所示：

#figure(
  image("image/实验4反例.png", width: 90%),
  caption: [ID规则在前的错误例子]
)

其次，浮点数规则应当写在整数规则之前。虽然 Lex/Flex 会进行最长匹配，但在实际书写规则时，将 float 放在 integer 前面可以使规则关系更加明确，避免浮点数被错误拆分。例如输入 2.13 时，应当整体识别为一个 FLOAT，而不是先识别出整数 2。

另外，对于关系运算符，也应当优先书写较长的符号。例如 <=、>=、<> 应放在 <、> 之前。这样可以避免短规则提前匹配导致歧义，也能使词法规则更符合从特殊到一般的书写习惯。

在具体规则动作中，关键字、分隔符和运算符只需要返回对应的 token 类型；而对于 ID、INT 和 FLOAT，则需要在返回 token 之前先给 yylval 赋值，如下所示。



```
 /* 浮点数必须放在整数前面 */
<INITIAL>{float}          {
                            yylval.fval = atof(yytext);
                            return FLOAT;
                          }

 /* 整数 */
<INITIAL>{integer}        {
                            yylval.ival = atoi(yytext);
                            return INT;
                          }

 /* 标识符 */
<INITIAL>{id}             {
                            yylval.sval = copy_string(yytext);
                            return ID;
                          }
```
                          
其中，浮点数通过 atof 转换后保存到 yylval.fval 中，整数通过 atoi 转换后保存到 yylval.ival 中，标识符则通过 copy_string 复制字符串后保存到 yylval.sval 中。

此外，程序还对空白符和注释进行了处理。空白符只起分隔作用，不需要作为 token 返回，因此直接忽略。对于块注释，程序使用 COMMENT 状态进行处理：当识别到注释开始符号时进入 COMMENT 状态，在注释状态中忽略普通字符和换行，直到识别到注释结束符号后再回到 INITIAL 状态。这样可以保证注释内容不会参与词法分析，也不会影响最终 token 序列的输出。


* 4. 修改输出函数并完成整体扫描流程 *

在实验 3 中，writeout 函数主要使用 yytext 输出记号属性值。但本次实验要求 ID、INT 和 FLOAT 必须使用 yylval 中保存的属性值进行输出，因此需要对 writeout 函数进行修改，如下在展示了writeout的新增部分：

```c
case ID:
    fprintf(yyout, "(ID, \"%s\") ", yylval.sval);
    free(yylval.sval);
    yylval.sval = NULL;
    break;

case INT:
    fprintf(yyout, "(INT, \"%d\") ", yylval.ival);
    break;

case FLOAT:
    fprintf(yyout, "(FLOAT, \"%.6f\") ", yylval.fval);
    break;

case INTEGER:
    fprintf(yyout, "(INTEGER, \"%s\") ", yytext);
    break;
```

对于 ID，程序输出 yylval.sval 中保存的标识符字符串。由于该字符串是通过 malloc 动态分配的，因此输出完成后需要调用 free(yylval.sval) 释放空间，并将其置为 NULL，避免内存泄漏和野指针问题。

对于 INT，程序输出 yylval.ival 中保存的整数值。
对于 FLOAT，程序输出 yylval.fval 中保存的浮点数值，并使用 %.6f 保留六位小数。这样即使输入为 .49，输出时也可以统一显示为 0.490000，符合实验要求。

对于关键字、运算符和分隔符等其他 token，则仍然可以使用 yytext 输出其原始词素内容。

主函数的整体流程与实验 3 基本一致。程序首先根据命令行参数打开输入文件和输出文件，然后循环调用 yylex。每次 yylex 返回一个 token 后，程序立即调用 writeout 输出对应的二元组，并统计已经输出的 token 数量。每输出五个 token，就额外输出一个换行，以满足实验要求的输出格式。

其核心流程如下：

```c
while ((c = yylex()) != 0) {
    writeout(c);
    j++;
    if (j % 5 == 0) {
        writeout(NEWLINE);
    }
}
```

当 yylex 返回 0 时，说明输入文件已经扫描结束，词法分析过程结束。最后关闭相关文件，完成整个程序的运行流程。

通过以上修改，词法分析器不仅能够正确识别各类 token，还能够为标识符、整数和浮点数保存并输出对应属性值，从而满足本次实验关于 yylval 属性传递的要求。


#exp-section(5, "实验结果")

#figure(
  image("image/实验4结果.png", width: 77%),
  caption: [3组测试用例通过截图]
)

#exp-section(6, "实验中遇到的问题、难点及解决方案")

*1. yylval 为什么要使用 union 类型？ *

在实验最开始，容易认为 yylval 可以继续使用 int 类型，因为实验 3 中的 token 只需要返回记号类型即可。但是本次实验要求不同类型的记号携带不同类型的属性值。标识符的属性是字符串，整数的属性是 int，浮点数的属性是 double。如果 yylval 仍然定义为 int，就无法同时保存这些不同类型的数据。
因此，本实验将 yylval 定义为 union 类型。union 的特点是同一块内存可以按照不同成员解释，因此可以根据当前 token 的类型，选择使用 ival、fval 或 sval 保存属性值。这样既满足了实验要求，也与 Yacc/Bison 中常见的 %union 机制相对应。


*2. 为什么标识符不能直接让 yylval.sval 指向 yytext？*

yytext 是 Lex/Flex 内部用于保存当前匹配词素的缓冲区。每次 yylex 继续匹配新的 token 时，yytext 的内容都会发生变化。如果直接写成 yylval.sval = yytext，那么 yylval.sval 指向的内容可能会在下一次匹配时被覆盖。
因此，对于标识符字符串，需要使用 malloc 重新分配空间，并将 yytext 中的内容复制过去。这样即使 yytext 后续改变，yylval.sval 中保存的标识符字符串仍然是正确的。本实验通过 copy_string 函数解决了这个问题。

* 3.	标识符字符串需要释放内存*

由于 copy_string 函数中使用 malloc 为标识符字符串分配了内存，如果只分配不释放，会造成内存泄漏。虽然本实验测试程序规模较小，即使不释放也可能不会立即产生明显问题，但从程序设计规范和后续扩展角度来看，应该及时释放不再使用的动态内存。
因此在 writeout 函数输出 ID 记号后，程序调用 free(yylval.sval) 释放空间，并将 yylval.sval 设置为 NULL。

* 4.	浮点数规则必须放在整数规则之前 *

在 Lex/Flex 中，如果整数规则写在浮点数规则之前，可能会导致浮点数不能被正确识别。例如输入 2.13 时，如果先识别整数，就可能先匹配到 2，之后再处理 .13，最终导致输出结果错误。
因此，本实验将浮点数规则放在整数规则之前。这样当输入中出现浮点数时，词法分析器会优先按照浮点数规则进行匹配，并返回 FLOAT 记号。

* 5.	BEGIN 不能直接作为 token 名*

实验过程中还需要注意 BEGIN 是 Lex/Flex 中用于状态切换的宏。例如在处理注释时，需要使用 BEGIN(COMMENT) 切换到 COMMENT 状态。如果将 BEGIN 定义为普通 token 宏，可能会与 Lex/Flex 自身机制发生冲突。
因此程序中使用 BEGINN 作为 token 名表示源程序中的 BEGIN 关键字，在 writeout 输出时再打印为 BEGIN。这样既避免了命名冲突，又保证了输出结果符合实验要求。

* 6.	浮点数输出格式问题 *

实验要求浮点数输出时保留六位小数。如果直接使用 yytext 输出，那么输入 .49 时会输出 .49，而不是实验要求中的 0.490000。如果直接使用 %f 输出 double 类型，默认正好保留六位小数，但为了明确格式，本实验在 writeout 中使用 %.6f 输出 yylval.fval。
这样不论输入是 .49、2.13 还是 12E3，都可以按照统一的浮点数格式输出。


#exp-section(7, "感想和收获")

通过本次实验，我对 Lex/Flex 词法分析器的工作方式有了更深入的理解。实验 3 主要完成 token 的识别，而本次实验进一步要求为 token 设置属性值，使我认识到词法分析器不仅要判断输入串属于哪类记号，还要将其携带的具体信息传递给后续语法分析阶段。

本次实验的核心是 `yylval` 的使用。通过将 `yylval` 定义为 `union` 类型，可以让它保存字符串、整数、浮点数等不同类型的属性值。这样，语法分析器不仅能知道当前 token 是 `ID`、`INT` 还是 `FLOAT`，还能获得标识符名称、整数值和浮点数值等具体信息。

此外，我也进一步理解了词法规则书写顺序的重要性。例如关键字规则应放在标识符规则之前，浮点数规则应放在整数规则之前，较长的运算符规则应放在较短规则之前，否则可能导致错误匹配。

在字符串处理方面，我认识到 `yytext` 只是临时匹配文本，若需要长期保存，必须复制到新的内存空间中，并注意后续释放，避免内存泄漏。

总的来说，本次实验让我从“识别 token”过渡到“识别 token 并传递属性值”，加深了对 Lex 与 Yacc/Bison 衔接机制的理解。


#exp-section(8, "小组分工情况")

#block[
  #set par(first-line-indent: 0em)

  #align(left)[
    #grid(
      columns: (auto, auto, 1fr),
      column-gutter: 0.2em,
      row-gutter: 0.6em,

      align(left)[啊~~~~吧], [：], [实验3（50%）、实验3报告],
      align(left)[双份追], [：], [实验4（50%、实验4报告],
      align(left)[爱哭鬼], [：], [实验4（50%）、实验4报告],
      align(left)[阿婆和], [：], [实验3（50%）、实验3报告、实验报告整合],
    )
  ]
]



