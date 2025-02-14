
/
    @file
        unit_escCode.q
    
    @description
        Unit tests for escCode.q
\

.pkg.load `cast`unit;

system "l ",.cast.htostr .Q.dd[PATH_SRC;`doc.q];

// Hide stderr output
STDOUT:STDERR:(::);

// Test data
.unit.doc.lineComment:([] 
    num:enlist 100; 
    line:enlist "// This is not the line you are looking for"
 );
.unit.doc.untaggedFunc:([]
    num:101 102;
    line:("// Neither is this"; "untaggedFunc:{x+y};")
 );
.unit.doc.fileMeta:([]
    num:1 2 3 4 5 6;
    line:(
        enlist"/";
        "@file";
        "    file.q";
        "@description";
        "    File description";
        enlist"\\"
    )
 );
.unit.doc.docFunc:`content`lines!(
    ([]
        num:7 8 9 10;
        line:(
            "// @brief Brief description.";
            "// @param paramName Symbol Parameter description.";
            "// @return Symbol Return value description.";
            "docFunc:{[paramName] paramName+1};"
        )
    );
    ([]
        tag:`brief`param`return;
        items:(
            (1#`)!1#(::);
            ``name`types!(::;`paramName;enlist`Symbol);
            ``types!(::;enlist`Symbol)
        );
        text:("Brief description."; "Parameter description."; "Return value description.");
        num:7 8 9;
        grp:3#0N;
        fnum:10;
        fname:3#`docFunc;
        fparams:3#enlist enlist`paramName
    )
 );
.unit.doc.otherFunc:`content`lines!(
    ([]
        num:12 13 14 15;
        line:(
            "// @brief Other brief description.";
            "// @param otherParamName Symbol Other parameter description.";
            "// @return Symbol Other return value description.";
            "otherFunc:{[otherParamName] otherParamName+1};"
        )
    );
    ([]
        tag:`brief`param`return;
        items:(
            (1#`)!1#(::);
            ``name`types!(::;`otherParamName;enlist`Symbol);
            ``types!(::;enlist`Symbol)
        );
        text:(
            "Other brief description.";
            "Other parameter description.";
            "Other return value description."
        );
        num:12 13 14;
        grp:3#0N;
        fnum:15;
        fname:3#`otherFunc;
        fparams:3#enlist enlist`otherParamName
    )
 );
.unit.doc.singleTagged:`content`lines!(
    ([]
        num:16 17;
        line:(
            "// @brief A single tagged line.";
            "singleFunc:{10};"
        )
    );
    ([]
        tag:enlist `brief;
        items:enlist (1#`)!1#(::);
        text:enlist "A single tagged line.";
        num:enlist 16;
        grp:enlist 0N;
        fnum:enlist 17;
        fname:enlist `singleFunc;
        fparams:enlist`$()
    )
 );
.unit.doc.badFunc:`content`lines!(
    ([]
        num:19 20 21 22;
        line:(
            "// @badbrief A bad brief description...";
            "// @badparam badParam Symbol A bad parameter.";
            "// @badreturn Symbol A bad return value.";
            "badFunc:{x};"
        )
    );
    ([]
        tag:3#`;
        items:((1#`)!1#(::); (1#`)!1#(::); (1#`)!1#(::));
        text:(
            "@badbrief A bad brief description...";
            "@badparam badParam Symbol A bad parameter.";
            "@badreturn Symbol A bad return value."
        );
        num:19 20 21;
        grp:3#0N;
        fnum:3#22;
        fname:3#`badFunc;
        fparams:3#enlist `$()
    )
 );
.unit.doc.multilineBrief:`content`lines!(
    ([]
        num:24 25 26 27;
        line:(
            "// @brief A multiline";
            "// brief description...";
            "// @return Symbol A return value.";
            "multilineBriefFunc:{10};"
        )
    );
    ([]
        tag:`brief``return;
        items:((1#`)!1#(::); (1#`)!1#(::); ``types!(::;enlist`Symbol));
        text:(
            "A multiline";
            "brief description...";
            "A return value."
        );
        num:24 25 26;
        grp:3#0N;
        fnum:3#27;
        fname:3#`multilineBriefFunc;
        fparams:3#enlist `$()
    )
 );
.unit.doc.multilineReturn:`content`lines!(
    ([]
        num:29 30 31 32;
        line:(
            "// @brief Brief description";
            "// @return Symbol A multiline";
            "// return value.";
            "multilineReturnFunc:{x};"
        )
    );
    ([]
        tag:`brief`return`;
        items:((1#`)!1#(::); ``types!(::;enlist`Symbol); (1#`)!1#(::));
        text:(
            "Brief description";
            "A multiline";
            "return value."
        );
        num:29 30 31;
        grp:3#0N;
        fnum:3#32;
        fname:3#`multilineReturnFunc;
        fparams:3#enlist `$()
    )
 );

test_multilineCommentBlocks:{[]
    .unit.assert.match[enlist"";multilineCommentBlocks ()];
    .unit.assert.match[enlist"";multilineCommentBlocks ""];
    .unit.assert.match[enlist"";multilineCommentBlocks enlist ""];
    .unit.assert.match[enlist"";multilineCommentBlocks first .unit.doc.lineComment`line];
    .unit.assert.match[enlist"";multilineCommentBlocks .unit.doc.lineComment`line];
    .unit.assert.match[enlist"";multilineCommentBlocks .unit.doc.untaggedFunc`line];

    // Empty multiline comment block
    .unit.assert.match[enlist();] multilineCommentBlocks (enlist"/";enlist"\\");

    content:(
        enlist"/";
        "    I am a ";
        "    multiline comment";
        enlist"\\"
    );
    expected:enlist content 1 2;
    .unit.assert.match[expected;multilineCommentBlocks content];

    content,:(
        enlist"/";
        "    The ending backslash should be ignored \\";
        enlist"\\"
    );
    expected,:enlist content 5;
    .unit.assert.match[expected;multilineCommentBlocks content];
    
    content,:(
        enlist"/";
        enlist"/";
        enlist"/";
        enlist"\\"
    );
    expected,:content 8 9;
    .unit.assert.match[expected;multilineCommentBlocks content];
 };

test_fileMetaBlock:{[]
    .unit.assert.match[enlist"";fileMetaBlock ()];
    .unit.assert.match[enlist"";fileMetaBlock ""];
    .unit.assert.match[enlist"";fileMetaBlock enlist ""];
    .unit.assert.match[enlist"";fileMetaBlock .unit.doc.lineComment`line];
    .unit.assert.match[enlist"";fileMetaBlock first .unit.doc.lineComment`line];
    .unit.assert.match[enlist"";fileMetaBlock .unit.doc.untaggedFunc`line];
    .unit.assert.match[enlist"";] fileMetaBlock (
        enlist"/";
        "@badfile";
        "    badfile.q";
        "@baddescription";
        "    Not a valid file meta block";
        enlist"\\"
    );

    content:.unit.doc.fileMeta`line;
    expected:content 1 2 3 4;
    .unit.assert.match[expected;fileMetaBlock content];

    content,:(
        enlist"/";
        "@file";
        "    anotherfile.q";
        "@description";
        "    Another file description which should be ignored";
        enlist"\\"
    );
    .unit.assert.match[expected;fileMetaBlock content];
 };

test_extractDescription:{[]
    .unit.assert.match["";extractDescription ()];
    .unit.assert.match["";extractDescription ""];
    .unit.assert.match["";extractDescription enlist ""];
    .unit.assert.match["";extractDescription .unit.doc.lineComment`line];
    .unit.assert.match["";extractDescription first .unit.doc.lineComment`line];
    .unit.assert.match["";extractDescription .unit.doc.untaggedFunc`line];
    .unit.assert.match["";] extractDescription (
        enlist"/";
        "@badfile";
        "    badfile.q";
        "@baddescription";
        "    Not a file description";
        enlist"\\"
    );

    content:.unit.doc.fileMeta`line;
    expected:ltrim content 4;
    .unit.assert.match[expected;extractDescription content];

    content,:(
        enlist"/";
        "@file";
        "    anotherfile.q";
        "@description";
        "    Another file description which should be ignored";
        enlist"\\"
    );
    .unit.assert.match[expected;extractDescription content];
 };

test_groupContinuous:{[]
    .unit.assert.match[enlist "j"$();groupContinuous "j"$()];
    .unit.assert.match[enlist enlist 1;groupContinuous enlist 1];
    .unit.assert.match[enlist til 5;groupContinuous til 5];
    .unit.assert.match[(0 1 2;4 5 6);groupContinuous 0 1 2 4 5 6];
    .unit.assert.match[(0 1 2;4 5 6;8 9;enlist 100);groupContinuous 0 1 2 4 5 6 8 9 100];
    .unit.assert.match[(enlist -3;-1 0 1 2;4 5 6);groupContinuous -3 -1 0 1 2 4 5 6];
    .unit.assert.match[enlist 1 1 1;groupContinuous 1 1 1];
    .unit.assert.match[(1 1 1 2; 4 4);groupContinuous 1 1 1 2 4 4];
    .unit.assert.match[enlist each 1 0 -1;groupContinuous 1 0 -1];
 };

test_findLines:{[]
    .unit.assert.match[enlist "j"$();findLines ()];
    .unit.assert.match[enlist "j"$();findLines enlist""];
    .unit.assert.match[enlist "j"$();findLines .unit.doc.lineComment`line];
    .unit.assert.match[enlist "j"$();findLines .unit.doc.untaggedFunc`line];

    content:.unit.doc.docFunc[`content;`line];
    expected:enlist 0 1 2;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.docFunc[`content;`line];
    expected,:enlist 4 5 6;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.singleTagged[`content;`line];
    expected,:enlist enlist 8;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.untaggedFunc`line;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.fileMeta`line;
    .unit.assert.match[expected;findLines content];

    // Bad tagged lines are still identified
    content,:.unit.doc.badFunc[`content;`line];
    expected,:enlist 18 19 20;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.multilineBrief[`content;`line];
    expected,:enlist 22 23 24;
    .unit.assert.match[expected;findLines content];

    content,:.unit.doc.multilineReturn[`content;`line];
    expected,:enlist 26 27 28;
    .unit.assert.match[expected;findLines content];
 };

test_parseTypes:{[]
    .unit.assert.match[enlist`Symbol;parseTypes "Symbol"];
    .unit.assert.match[`Symbol`String;parseTypes "Symbol|String"];
    .unit.assert.match[`String`Symbol;parseTypes "String|Symbol"];
    .unit.assert.match[enlist`BadType;parseTypes "BadType"];
    .unit.assert.match[enlist`$"BadSep1&BadSep2";parseTypes "BadSep1&BadSep2"];
    .unit.assert.match[`Symbol`String`Float;parseTypes "Symbol|String|Float"];
    .unit.assert.match[`Symbol`String`;parseTypes "Symbol|String|"];
 };

test_parseLine:{[]
    .unit.assert.match[`tag`items`text!(`$();(1#`)!1#(::);());parseLine ""];
    
    r:parseLine "// Not tagged.";
    .unit.assert.match[`;r`tag];
    .unit.assert.match[(1#`)!1#(::);r`items];
    .unit.assert.match["Not tagged.";r`text];

    r:parseLine "// @badtag Bad tag.";
    .unit.assert.match[`;r`tag];
    .unit.assert.match[(1#`)!1#(::);r`items];
    .unit.assert.match["@badtag Bad tag.";r`text];

    r:parseLine "// @brief My description.";
    .unit.assert.match[`brief;r`tag];
    .unit.assert.match[(1#`)!1#(::);r`items];
    .unit.assert.match["My description.";r`text];

    r:parseLine "// @param myParam Symbol My paramter.";
    .unit.assert.match[`param;r`tag];
    .unit.assert.match[(``name`types)!((::);`myParam;enlist `Symbol);r`items];
    .unit.assert.match["My paramter.";r`text];

    r:parseLine "// @param myOtherParam Symbol|String My other paramter.";
    .unit.assert.match[`param;r`tag];
    .unit.assert.match[(``name`types)!((::);`myOtherParam;`Symbol`String);r`items];
    .unit.assert.match["My other paramter.";r`text];

    r:parseLine "// @return Symbol My return value.";
    .unit.assert.match[`return;r`tag];
    .unit.assert.match[(``types)!((::);enlist `Symbol);r`items];
    .unit.assert.match["My return value.";r`text];

    r:parseLine "// @return Symbol|String My other return value.";
    .unit.assert.match[`return;r`tag];
    .unit.assert.match[(``types)!((::);`Symbol`String);r`items];
    .unit.assert.match["My other return value.";r`text];

    r:parseLine "// @example My example.";
    .unit.assert.match[`example;r`tag];
    .unit.assert.match[(1#`)!1#(::);r`items];
    .unit.assert.match["My example.";r`text];
 };

test_extractParams:{[]
    .unit.assert.match[`$(); extractParams ""];
    .unit.assert.match[`$(); extractParams "blah"];
    .unit.assert.match[`$(); extractParams "{}"];
    .unit.assert.match[`$(); extractParams "{[] 1+2}"];

    // Implicit args are not identified
    .unit.assert.match[`$(); extractParams "{x+y}"];
    
    .unit.assert.match[`$(); extractParams "@[hdel;;()]"];

    .unit.assert.match[enlist`param1; extractParams "{[param1] param1+1}"];
    .unit.assert.match[`param1`param2; extractParams "{[param1;param2] param1+param2}"];
    .unit.assert.match[
        `param1`param2`param3; 
        extractParams "{[param1;\nparam2;\n\t  param3] param1+param2+param3}"
    ];
 };

test_hasUnusedParams:{[]
    funcs:([grp:0 1]
        fnum:3 10;
        fname:`func1`func2;
        fparams:(enlist`param1;`param1`param2);
        docParams:(enlist`param1;`param1`param2);
        num:(enlist 2;8 9)
    );

    .unit.assert.false hasUnusedParams funcs;
    .unit.assert.true hasUnusedParams funcs upsert (2;20;`func3;enlist`param1;`param1`param2;18 19);
    .unit.assert.true hasUnusedParams funcs upsert (2;20;`func3;`$();enlist`param1;enlist 19);
    .unit.assert.false hasUnusedParams funcs upsert (2;20;`func3;enlist`param1;`$();enlist 19);
    .unit.assert.false hasUnusedParams funcs upsert 
        (2;20;`func3;`param1`param2;`param2`param1;18 19);
 };

test_hasMismatchedParams:{[]
    funcs:([grp:0 1]
        fnum:3 10;
        fname:`func1`func2;
        fparams:(enlist`param1;`param1`param2);
        docParams:(enlist`param1;`param1`param2);
        num:(enlist 2;8 9)
    );

    .unit.assert.false hasMismatchedParams funcs;
    .unit.assert.true hasMismatchedParams funcs upsert 
        (2;20;`func3;enlist`param1;enlist`param2;enlist 19);
    .unit.assert.true hasMismatchedParams funcs upsert (2;20;`func3;`$();enlist`param1;enlist 19);
    .unit.assert.true hasMismatchedParams funcs upsert (2;20;`func3;enlist`param1;`$();enlist 19);
    .unit.assert.true hasMismatchedParams funcs upsert 
        (2;20;`func3;`param1`param2;`param2`param1;18 19);
 };

test_buildLinesTab:{[]
    .unit.assert.match[();buildLinesTab ()];
    .unit.assert.match[();buildLinesTab ([] num:`long$(); line:())];
    .unit.assert.match[();buildLinesTab .unit.doc.lineComment];
    .unit.assert.match[();buildLinesTab .unit.doc.untaggedFunc];

    content:.unit.doc.docFunc`content;
    expected:update grp:3#0 from .unit.doc.docFunc`lines;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.otherFunc`content;
    expected,:update grp:3#1 from .unit.doc.otherFunc`lines;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.singleTagged`content;
    expected,:update grp:1#2 from .unit.doc.singleTagged`lines;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.untaggedFunc;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.fileMeta;
    .unit.assert.match[expected;buildLinesTab content];

    // Bad tagged lines are still identified
    content,:.unit.doc.badFunc`content;
    expected,:update grp:3 from .unit.doc.badFunc`lines;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.multilineBrief`content;
    expected,:update grp:4 from .unit.doc.multilineBrief`lines;
    .unit.assert.match[expected;buildLinesTab content];

    content,:.unit.doc.multilineReturn`content;
    expected,:update grp:5 from .unit.doc.multilineReturn`lines;
    .unit.assert.match[expected;buildLinesTab content];

    // Implicit parameter x is identified
    content,:([]
        num:34 35 36;
        line:(
            "// @brief Brief description";
            "// @param x Long Implicit parameter.";
            "implicitFunc:{x+1}"
        )
    );
    expected,:([]
        tag:`brief`param;
        items:((1#`)!1#(::); ``name`types!(::;`x;enlist`Long));
        text:(
            "Brief description";
            "Implicit parameter."
        );
        num:34 35;
        grp:2#6;
        fnum:2#36;
        fname:2#`implicitFunc;
        fparams:2#enlist enlist `x
    );
    .unit.assert.match[expected;buildLinesTab content];
 };

test_filterLines:{[]
    flt:("*.priv.*";"*.internal.*");

    .unit.assert.match[();filterLines[();enlist""]];
    .unit.assert.match[();filterLines[();flt]];

    content:raze (
        .unit.doc.docFunc`content;
        .unit.doc.otherFunc`content;
        .unit.doc.singleTagged`content;
        .unit.doc.untaggedFunc;
        .unit.doc.fileMeta;
        .unit.doc.badFunc`content;
        .unit.doc.multilineBrief`content;
        .unit.doc.multilineReturn`content
    );
    lines:buildLinesTab content;
    expected:raze (
        update grp:0 from .unit.doc.docFunc`lines;
        update grp:1 from .unit.doc.otherFunc`lines;
        update grp:2 from .unit.doc.singleTagged`lines;
        update grp:3 from .unit.doc.badFunc`lines;
        update grp:4 from .unit.doc.multilineBrief`lines;
        update grp:5 from .unit.doc.multilineReturn`lines
    );
    .unit.assert.match[expected;filterLines[lines;enlist""]];
    .unit.assert.match[expected;filterLines[lines;flt]];

    content,:([]
        num:34 35;
        line:(
            "// @brief This function should be ignored when filters applied.";
            ".priv.ignoredFunc:{x};"
        )
    );
    lines:buildLinesTab content;
    .unit.assert.match[expected;filterLines[lines;flt]];
    // Unfiltered should have the new row
    expected,:([]
        tag:enlist `brief;
        items:enlist (1#`)!1#(::);
        text:enlist "This function should be ignored when filters applied.";
        num:enlist 34;
        grp:enlist 6;
        fnum:enlist 35;
        fname:enlist`.priv.ignoredFunc;
        fparams:enlist`symbol$()
    );
    .unit.assert.match[expected;filterLines[lines;enlist""]];
 };

test_mergeText:{[]
    .unit.assert.match[();mergeText ()];

    content:raze (
        .unit.doc.docFunc`content;
        .unit.doc.otherFunc`content;
        .unit.doc.singleTagged`content;
        .unit.doc.untaggedFunc;
        .unit.doc.fileMeta;
        .unit.doc.badFunc`content;
        .unit.doc.multilineBrief`content;
        .unit.doc.multilineReturn`content
    );
    lines:buildLinesTab content;

    mlblines:.unit.doc.multilineBrief`lines;
    txt:exec (" ",first text) from mlblines where null tag;
    mlblines:update (text:text,\:txt) from mlblines where tag=`brief;
    mlblines:update grp:4 from select from mlblines where not null tag;

    mlrlines:.unit.doc.multilineReturn`lines;
    txt:exec (" ",first text) from mlrlines where null tag;
    mlrlines:update (text:text,\:txt) from mlrlines where tag=`return;
    mlrlines:update grp:5 from select from mlrlines where not null tag;

    expected:raze (
        update grp:0 from .unit.doc.docFunc`lines;
        update grp:1 from .unit.doc.otherFunc`lines;
        update grp:2 from .unit.doc.singleTagged`lines;
        mlblines;
        mlrlines
    );
    .unit.assert.match[expected;mergeText lines];
 };

test_identifyRepeated:{[]
    .unit.assert.match[`long$();identifyRepeated[();`]];
    .unit.assert.match[`long$();identifyRepeated[();`brief]];

    uniqueTab:([grp:0 1 2 3] 
        tag:(`brief`return; enlist`brief; `brief`brief`return; `brief`return`return); 
        num:(1 3; enlist 9; 19 20 21; 23 24 25)
    );
    .unit.assert.match[enlist 20;identifyRepeated[uniqueTab;`brief]];
    .unit.assert.match[enlist 25;identifyRepeated[uniqueTab;`return]];

    uniqueTab:([grp:0 1 2] 
        tag:(`brief`brief`brief`return; `brief`brief`brief; `return`brief`return`return); 
        num:(1 2 3 4; 6 7 8; 10 11 13 14)
    );
    .unit.assert.match[2 3 7 8;identifyRepeated[uniqueTab;`brief]];
    .unit.assert.match[13 14;identifyRepeated[uniqueTab;`return]];
 };

test_removeRepeated:{[]
    .unit.assert.match[();removeRepeated ()];

    content:raze (
        .unit.doc.docFunc`content;
        .unit.doc.otherFunc`content;
        .unit.doc.singleTagged`content;
        .unit.doc.untaggedFunc;
        .unit.doc.fileMeta
    );
    lines:buildLinesTab content;
    expected:raze (
        update grp:0 from .unit.doc.docFunc`lines;
        update grp:1 from .unit.doc.otherFunc`lines;
        update grp:2 from .unit.doc.singleTagged`lines
    );
    .unit.assert.match[expected;removeRepeated lines];

    content,:([]
        num:19 20 21 22;
        line:(
            "// @brief Brief description.";
            "// @brief Duplicated brief description.";
            "// @return Symbol Return value description.";
            "dupBriefFunc:{x};"
        )
    );
    lines:buildLinesTab content;
    expected,:([]
        tag:`brief`return;
        items:(
            (1#`)!1#(::);
            ``types!(::;enlist`Symbol)
        );
        text:("Brief description."; "Return value description.");
        num:19 21;
        grp:2#3;
        fnum:2#22;
        fname:2#`dupBriefFunc;
        fparams:2#enlist `$()
    );
    .unit.assert.match[expected;removeRepeated lines];

    content,:([]
        num:24 25 26 27;
        line:(
            "// @brief Brief description.";
            "// @return Symbol Return value description.";
            "// @return Symbol Duplicated return value description.";
            "dupReturnFunc:{x};"
        )
    );
    lines:buildLinesTab content;
    expected,:([]
        tag:`brief`return;
        items:(
            (1#`)!1#(::);
            ``types!(::;enlist`Symbol)
        );
        text:("Brief description."; "Return value description.");
        num:24 25;
        grp:2#4;
        fnum:2#27;
        fname:2#`dupReturnFunc;
        fparams:2#enlist `$()
    );
    .unit.assert.match[expected;removeRepeated lines];

    // Can have multiple examples
    content,:([]
        num:29 30 31 32;
        line:(
            "// @brief Brief description.";
            "// @example First example.";
            "// @example Second example.";
            "dupExampleFunc:{x};"
        )
    );
    lines:buildLinesTab content;
    expected,:([]
        tag:`brief`example`example;
        items:((1#`)!1#(::); (1#`)!1#(::); (1#`)!1#(::));
        text:("Brief description."; "First example."; "Second example.");
        num:29 30 31;
        grp:3#5;
        fnum:3#32;
        fname:3#`dupExampleFunc;
        fparams:3#enlist `$()
    );
    .unit.assert.match[expected;removeRepeated lines];

    // Only 1 kept, others discarded
    content,:([]
        num:34 35 36 37;
        line:(
            "// @brief Brief description 1.";
            "// @brief Brief description 2.";
            "// @brief Brief description 3.";
            "brief3Func:{x};"
        )
    );
    lines:buildLinesTab content;
    expected,:([]
        tag:enlist `brief;
        items:enlist(1#`)!1#(::);
        text:enlist "Brief description 1.";
        num:enlist 34;
        grp:enlist 6;
        fnum:enlist 37;
        fname:enlist `brief3Func;
        fparams:enlist `$()
    );
    .unit.assert.match[expected;removeRepeated lines];
 };

test_validateLine:{[]
    .unit.assert.true validateLine ();
    .unit.assert.true validateLine (`$())!();

    content:raze (
        .unit.doc.docFunc`content;
        .unit.doc.otherFunc`content;
        .unit.doc.singleTagged`content;
        .unit.doc.untaggedFunc;
        .unit.doc.fileMeta
    );
    lines:buildLinesTab content;
    .unit.assert.true all validateLine each lines;

    line:`tag`items`text`num`grp`fname!(`;enlist[`]!enlist ::;"";1;0;`);
    .unit.assert.true validateLine line;
    
    line[`tag]:`bad;
    .unit.assert.false validateLine line;

    line[`tag]:`param;
    line[`items]:`name`types!(`parmName;enlist`Symbol);
    .unit.assert.true validateLine line;

    line[`items]:`name`types!(`parmName;enlist`symbol);
    .unit.assert.true validateLine line;

    line[`items]:`name`types!(`parmName;enlist`badType);
    .unit.assert.false validateLine line;
 };

test_md:{[]
    emptyItems:(1#`)!1#(::);
    
    .unit.assert.match["My description";.md.brief[emptyItems;"My description"]];

    .unit.assert.match[
        "|myParam|Symbol|My parameter.|";
        .md.param[``name`types!((::);`myParam;enlist `Symbol);"My parameter."]
    ];
    .unit.assert.match[
        "|myOtherParam|Symbol,String|My other parameter.|";
        .md.param[``name`types!((::);`myOtherParam;`Symbol`String);"My other parameter."]
    ];

    .unit.assert.match[
        ("### Return";"* **Type(s)**: Symbol";"* **Description**: My return value.");
        .md.return[``types!((::);enlist `Symbol);"My return value."]
    ];
    .unit.assert.match[
        ("### Return";"* **Type(s)**: Symbol,String";"* **Description**: My other return value.");
        .md.return[``types!((::);`Symbol`String);"My other return value."]
    ];

    .unit.assert.match[("```q";"My example";"```");.md.example[emptyItems;"My example"]];
 };

test_genFuncMD:{[]
    fdoc:`tag`items`text`num`fnum`fname`fparams!(
        `brief`param`return;
        (
            enlist[`]!enlist::;
            ``name`types!(::;`paramName;enlist`Symbol);
            ``types!(::;enlist`Symbol)
        );
        ("Brief description."; "Parameter description."; "Return value description.");
        1 2 3;
        3#4;
        3#`docFunc;
        3#enlist `paramName
    );
    expected:(
        "## docFunc";
        "Brief description.";
        "### Syntax";
        "```q";
        "docFunc paramName";
        "```";
        "### Parameters";
        "|Parameter|Type(s)|Description|";
        "|-|-|-|";
        "|paramName|Symbol|Parameter description.|";
        "### Return";
        "* **Type(s)**: Symbol";
        "* **Description**: Return value description."
    );
    .unit.assert.match[expected;genFuncMD fdoc];

    fdoc:`tag`items`text`num`fnum`fname`fparams!(
        enlist `brief;
        enlist enlist[`]!enlist::;
        enlist "A single tagged line.";
        enlist 9;
        enlist 10;
        enlist`singleFunc;
        enlist `$()
    );
    expected:(
        "## singleFunc";
        "A single tagged line.";
        "### Syntax";
        "```q";
        "singleFunc[]";
        "```"
    );
    .unit.assert.match[expected;genFuncMD fdoc];

    fdoc:`tag`items`text`num`fnum`fname`fparams!(
        `brief`example;
        (enlist[`]!enlist::; enlist[`]!enlist::);
        ("Brief description."; "Some example");
        10 11;
        2#12;
        2#`exampleFunc;
        2#enlist `param1`param2
    );
    expected:(
        "## exampleFunc";
        "Brief description.";
        "### Syntax";
        "```q";
        "exampleFunc[param1;param2]";
        "```";
        "### Examples";
        "```q";
        "Some example";
        "```"
    );
    .unit.assert.match[expected;genFuncMD fdoc];
 };

test_convertToMD:{[]
    content:raze (
        .unit.doc.docFunc`content;
        .unit.doc.otherFunc`content;
        .unit.doc.singleTagged`content;
        .unit.doc.untaggedFunc;
        .unit.doc.fileMeta
    );
    outContent:`file`description`funcs!("file.q";"File description.";buildLinesTab content);
    expected:(
        "# file.q";
        "File description.";
        "## docFunc";
        "Brief description.";
        "### Syntax";
        "```q";
        "docFunc paramName";
        "```";
        "### Parameters";
        "|Parameter|Type(s)|Description|";
        "|-|-|-|";
        "|paramName|Symbol|Parameter description.|";
        "### Return";
        "* **Type(s)**: Symbol";
        "* **Description**: Return value description.";
        "## otherFunc";
        "Other brief description.";
        "### Syntax";
        "```q";
        "otherFunc otherParamName";
        "```";
        "### Parameters";
        "|Parameter|Type(s)|Description|";
        "|-|-|-|";
        "|otherParamName|Symbol|Other parameter description.|";
        "### Return";
        "* **Type(s)**: Symbol";
        "* **Description**: Other return value description.";
        "## singleFunc";
        "A single tagged line.";
        "### Syntax";
        "```q";
        "singleFunc[]";
        "```"
    );
    .unit.assert.match[expected;convertToMD outContent];
 };

.unit.add[`doc;] each 
    `test_multilineCommentBlocks`test_fileMetaBlock`test_extractDescription`test_groupContinuous,
    `test_findLines`test_parseTypes`test_parseLine`test_extractParams`test_hasUnusedParams,
    `test_hasMismatchedParams`test_buildLinesTab`test_filterLines`test_mergeText,
    `test_identifyRepeated`test_removeRepeated`test_validateLine`test_md`test_genFuncMD,
    `test_convertToMD;
