
/
    @file
        doc.q

    @description
        Generate code documentation from source files.

    @options
        |    Option    |            Description             |          Example          |
        | ------------ | ---------------------------------- | ------------------------- |
        | -ignore      | Function name(s) (regex) to ignore | '*.priv.*' '*.internal.*' |
        | -out         | Location of output files           | path/to/dir               | 
        | -src         | File(s) to generate docs for       | srcFile1.q srcFile2.q     |
\

STDOUT:-1;
STDERR:-2;

H1:"# ",;
H2:"## ",;
H3:"### ",;

DOC_COMMENT_OPEN:"// ";
DOC_COMMENT_START:DOC_COMMENT_OPEN,"@";

META_TAGS:`file`description;
META_TAGS_RGX:META_TAGS!{"*@",x,"*"} each string META_TAGS;
FUNC_TAGS:`brief`detail`param`return`example;
HAS_TYPE_TAGS:`param`return;

TYPES:`boolean`guid`byte`short`int`long`real`float`char`symbol`timestamp`month`date`datetime,
    `timespan`minute`second`time`enum`filesymbol;
TYPES:`list,raze TYPES,'`$string[TYPES],\:"s";
TYPES,:`string`table`dict`function`lambda`unary`operator`iterator`projection`composition`any;

// @brief Log a fatal error message and exit the program.
fatalError:{[]
    STDERR file,": Could not generate documentation";
    exit 1
 };

// @brief Find all multiline comment blocks within the given file content.
// @param content List File content.
// @return General List of multiline comment blocks.
multilineCommentBlocks:{[content]
    c:rtrim content;
    s:where c~\:enlist"/";
    e:where c~\:enlist "\\";
    s@:0,-1_?[;0b] each s</:e;
    if[count[s]<>count e; :enlist""];
    content {1+x+til y-1+x} ./: s,'e
 };

// @brief Get the file meta information block from the file content.
// @param content List File content.
// @return String File meta content block.
fileMetaBlock:{[content]
    i:?[;1b]{any raze[x] like/: META_TAGS_RGX} each b:multilineCommentBlocks content;
    $[i<count b; b i; enlist""]
 };

// @brief Extract a file description from the file content.
// @param content List File content.
// @return String File description.
extractDescription:{[content]
    d:trim fileMetaBlock content;
    i:where d[;0]="@";
    d:i cut d;
    tag:1_META_TAGS_RGX`description;
    d@:?[;1b] d[;0] like tag;
    d:(count -1_tag)_"\n" sv d;
    $[first d="\n";1_;] d
 };

// @brief Group continuous numbers together (gap is any increase of more than 1).
// @param x Longs Numbers to group.
// @return List Grouped numbers.
groupContinuous:{cut[;x] 0,where not deltas[first x;x] in 0 1};

// @brief Find all code documentation lines.
// @param content List File content.
// @return List Grouped line indices of code documentation lines.
findLines:{[content]
    i:groupContinuous docComments:where content like DOC_COMMENT_START,"*";
    commentLines:except[;docComments] where content like DOC_COMMENT_OPEN,"*";
    i:{@[x;where (y-1)=last each x;,;y]}/[i;commentLines];
    groupContinuous raze i
 };

// @brief Parse the types item of a documentation line.
// @param types String Types part of documentation line.
// @return Symbols Parsed datatypes.
parseTypes:{[types] `$"|" vs types};

// @brief Parse a documentation line.
// @param Line String Line to parse.
// @return Dict Line items.
parseLine:{[line]
    items:`tag`items`text!(`$();(1#`)!1#(::);());
    if[0=count line; :items];
    line:1_" " vs line;
    $[(tag:`$1_first line) in FUNC_TAGS; line:1_line; tag:`];
    $[
        tag=`param; [
            items[`items;`name]:`$line 0; 
            items[`items;`types]:parseTypes line 1; 
            line:2_line
        ];
        tag=`return; [
            items[`items;`types]:parseTypes line 0; 
            line:1_line
        ];
    ];
    items[`tag]:tag;
    items[`text]:" " sv line;
    items
 };

// @brief Parse a function to extract its parameters.
// @param x String Function string.
// @return Symbols Parameters.
extractParams:{
    x:x except "\n\t ";
    if["{"=first x; x:1_x];
    $["["=first x; 
        $[count x:1_(x?"]")#x; `$";" vs x; `$()];
        `$()
    ]
 };

// @brief Check if any params are docuemented but are unused. Log if so.
// @param funcs Table Grouped function documentation.
// @return Boolean 1b if there are unused, 0b otherwise.
hasUnusedParams:{[funcs]
    unused:select from funcs where 
        (count each fparams)<{count x except `x`y`z} each docParams;
    if[count unused; 
        {
            i:where not x[`docParams] in x[`params],`x`y`z;
            {
                STDOUT "[",string[y],"] Param documented but unused: ",string x
            }'[x[`docParams;i];x[`num;i]]
        } each unused;
        :1b
    ];
    0b
 };

// @brief Check if there are any mismatches between actual and documented params. Log if so.
// @param funcs Table Grouped function documentation.
// @return Boolean 1b if there are mismatches, 0b otherwise.
hasMismatchedParams:{[funcs]
    if[count unmatched:select from funcs where not fparams~'docParams;
        {
            STDERR "[",string[x`fnum],"] Parameter mismatch: Actual = ",
                ("," sv string x`fparams)," | Documented = ","," sv string x`docParams
        } each unmatched;
        :1b
    ];
    0b
 };

// @brief Build a table used to organise information about each line.
// @param content List Grouped file content.
// @return Table Lines table.
buildLinesTab:{[content]
    if[0=count content; :()];

    idx:findLines content`line;
    if[idx~enlist `long$(); :()];
    
    lines:content ridx:raze idx;
    lines:update num:lines`num from parseLine each lines`line;
    countGrps:count each idx;
    lines:update grp:raze countGrps#'til count idx from lines;
    
    fidx:1+last each idx;
    funcs:":" vs/:content[`line] fidx;
    funcs:([grp:til count countGrps]
        fnum:content[`num] fidx;
        fname:`$funcs[;0];
        fparams:(asc extractParams@) each funcs[;1]
    );

    funcs:funcs lj select docParams:asc items`name, num by grp from lines where tag=`param;
    hasUnusedParams funcs;

    funcs:update fparams:docParams inter\: `x`y`z from funcs where 0=count each fparams;
    if[hasMismatchedParams funcs; fatalError[]];
    
    lines lj `grp xkey select grp, fnum, fname, fparams from funcs
 };

// @brief Remove ignored documentation lines.
// @param lines Tables Lines table.
// @param ignoreFnames List List of function names (regex) to ignore.
// @return Table Filtered lines table.
filterLines:{[lines;ignoreFnames] 
    $[count lines; lines where not any lines[`fname] like/: ignoreFnames; ()]
 };

// @brief Merge text across continued lines.
// @param Lines Table Lines table.
// @return Table Merged lines table.
mergeText:{[lines]
    if[0=count lines; :lines];
    nullTags:reverse exec i from lines where null tag;
    lines:{if[x[y-1;`num]=x[y;`num]-1; x[y-1;`text],:" ",rtrim x[y;`text]]; x}/[lines;nullTags];
    select from lines where not null tag
 };

// @brief Identify repeated tags that should be unique.
// @param uniqueTab Table Unique tag grouping table.
// @param t Symbol Tag to identify.
// @return Longs Line numbers of repeated tag occurences.
identifyRepeated:{[uniqueTab;t]
    if[0=count uniqueTab; :`long$()];
    b:exec t=tag from uniqueTab;
    idx:where 1<sum each b;
    if[count idx;
        nums:raze exec 1_/:num[idx]@'where each b idx from uniqueTab;
        {[t;n] STDERR "[",string[n],"] Ignored as ",string[t]," tag already defined"}[t;] each nums
    ];
    nums
 };

// @brief Remove repeated tags that should be unique.
// @param Lines Table Lines table.
// @return Table Lines table with repeated unique tags removed.
removeRepeated:{[lines]
    if[0=count lines; :lines];
    uniqueTags:`brief`return;
    uniqueTab:select tag, num by grp from select tag, num, grp from lines where tag in uniqueTags;
    nums:raze identifyRepeated[uniqueTab;] each uniqueTags;
    delete from lines where num in nums
 };

// @breif Validate a documentation line.
// @param line String Line.
// @param num Longs Line number.
// @return Boolean 1b if valid, 0b otherwise.
validateLine:{[line]
    if[0=count line; :1b];
    if[null tag:line`tag; :1b];
    
    valid:1b;
    
    if[not tag in FUNC_TAGS; 
        STDERR "[",string[line`num],"] Unknown tag: ",string tag;
        valid:0b
    ];

    if[tag in HAS_TYPE_TAGS;
        types:line[`items;`types];
        if[not all b:lower[types] in TYPES;
            STDERR "[",string[line`num],"] Invalid type(s): ","," sv string types where not b;
            STDERR "Valid types: ",", " sv string TYPES;
            valid:0b
        ]
    ];

    valid
 };

// @brief Parse code documentation for the given source file.
// @param src FileSymbol A Q source file.
// @param ignoreFnames List List of function names (regex) to ignore.
// @return Dict Parsed file content.
parseSrc:{[src;ignoreFnames]
    file:string last ` vs src;
    rawContent:read0 src;
    content:flip `num`line!.Q.ld rawContent;
    outContent:`file`description`funcs!(file;"";"");

    if[0=count outContent[`description]:extractDescription rawContent; 
        STDOUT file,": No file description found"
    ];

    lines:buildLinesTab content;
    lines:filterLines[lines;ignoreFnames];
    lines:mergeText lines;
    lines:removeRepeated lines;    

    if[not all validateLine each lines; fatalError[]];

    outContent[`funcs]:lines;
    outContent
 };

// @brief Wrap a string.
// @param x String String to wrap with.
// @param y String String to wrap.
// @return String Wrapped string.
wrap:{x,y,x};

// @brief Generate markdown for the specified tag.
// @param items Dict Documentation items.
// @param text String Documentation text.
// @return String Markdown.
.md.brief:{[items;text] text};
.md.param:{[items;text]
    items:string items;
    wrap["|";] "|" sv (items`name;"," sv items`types;text)
 };
.md.return:{[items;text]
    md:enlist H3 "Return";
    md,:("* **Type**: ";"* **Description**: "),'("," sv string items`types;text);
    md
 };
.md.example:{[items;text] ("```q";text;"```")};

// @brief Generate markdown for the given function documentation.
// @param fdoc Dict Function documentation.
// @return String Markdown.
genFuncMD:{[fdoc]
    fname:string first fdoc`fname;
    md:enlist H2 fname;

    fdoc:update md:.md[tag].'flip (items;text) from flip fdoc;
    tags:distinct fdoc`tag;

    md,:exec md from fdoc where tag=`brief;
    md,:enlist H3 "Syntax";

    syntax:fname,$[1=count p:first fdoc`fparams; " ",string first p; "[",(";" sv string p),"]"];
    md,:.md.example[();syntax];

    if[`param in tags;
        md,:(H3 "Parameters";"|Parameter|Type|Description|";"|-|-|-|");
        md,:exec md from fdoc where tag=`param
    ];
    md,:raze exec md from fdoc where tag=`return;
    if[`example in tags;
        md,:enlist H3 "Examples";
        md,:raze exec md from fdoc where tag=`example
    ];

    md
 };

// @brief Convert code documetation into markdown.
// @param content Dict Parsed file content.
// @return String Content in markdown format.
convertToMD:{[content]
    md:@[content`file`description;0;H1];
    fdocs:`grp xgroup content`funcs;
    md,:raze genFuncMD each value fdocs;
    md
 };

// @brief Generate a code documentation file for the given source file.
// @param out FileSymbol Directory to place output file in.
// @param src FileSymbol A Q source file.
// @param ignoreFnames List List of function names (regex) to ignore.
generateDoc:{[out;src;ignoreFnames]
    content:parseSrc[src;ignoreFnames];
    md:convertToMD content;
    file:.Q.dd[out;] ` sv (first` vs last ` vs src),`md;
    file 0: md;
    STDOUT "Generated doc: ",1_string file;
 };

// @brief Driver.
// @param opts Dict Command line options.
main:{[opts]
    if[count opts`src;
        (generateDoc[hsym opts`out;;opts`ignore] hsym@) each opts`src;
        exit 0
    ]
 };

main .Q.def[(`out`src`ignore)!(`.;`$();enlist"");.Q.opt .z.x];
