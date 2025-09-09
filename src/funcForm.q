
/
    @file 
        funcForm.q
    
    @description
        Convert a QSQL query into the equivalent function form.
        Adapted from https://code.kx.com/q/basics/funsql/

    @usage
        q funcForm.q <QSQL Query> -q
    
    @example
        q funcForm.q "select from table" -q
\

\c 2000 2000
stdout:-1;
stderr:-2;
usage:"Usage: q funcForm.q <QSQL Query>";

// @brief Wrap a string.
// @param x String Left wrap.
// @param y String Right wrap.
// @param z String Value to be wrapped.
// @return String Wrapped value.
wrap:{x,z,y};

// @brief Remove tags (used to distinguish replacement strings from actual strings). 
// @param x Any Object that might need tags removed.
// @return String Object with any tags removed.
removeTags:{ssr/[;("\"~~";"~~\"");("";"")] $[","=first x;1_x;x]};

// @brief Replace K function representation with its equivalent Q keyword.
// @param x Any Object that might need replacements.
// @return String Object with any replacements made.
replaceFunc:{$[`=qval:.q?x; x; wrap["~~";"~~";string qval]]};

// @brief Replace K functions representation with its equivalent Q keyword.
// @param x Any Object that might need replacements.
// @return String Object with any replacements made.
replaceFuncs:{$[0=t:type x; .z.s each x; t<100h; x; replaceFunc x]};

// @brief Replace , with enlist.
// @param x Any Object that needs replacements.
// @return String Object with replacements made.
replaceEnlist0:{wrap["~~";"~~";] "enlist",.Q.s1 first x};

// @brief Check if an object needs to be enlisted.
// @param x Any Object to check.
// @return Boolean 1b if object needs enlised, 0b otherwise.
needsEnlisted:{(1=count x) and ((0=type x) and 11=type first x) or 11=type x};

// @brief Replace , with enlist.
// @param x Any Object that might need replacements.
// @return String Object with any replacements made.
replaceEnlist:{$[needsEnlisted x; replaceEnlist0 x; 0=type x; .z.s each x; x]};

// @brief Replace K syntax with Q syntax.
// @param x Any Object that might need replacements.
// @return String Object with any replacements made.
kreplace0:{$[(0=type x) and 1=count x;"enlist ";""],removeTags .Q.s1 replaceFuncs replaceEnlist x};

// @brief Replace K syntax with Q syntax.
// @param x Any Object that might need replacements.
// @return String Object with any replacements made.
kreplace:{
    $[
        (0=count x) or -1=type x; .Q.s1 x;
        99=type x; (wrap["(";")";] kreplace0 key x),"!",kreplace0 value x;
        kreplace0 x
    ] 
 };

// @brief Convert a QSQL query to function form.
// @param ptree List Parse tree of parsed QSQL query.
// @return String Converted query.
convertQuery:{[ptree]
    idxs:2 3 4 5 6 inter argIdxs:til count ptree;
    ptree:@[ptree;idxs;kreplace eval@];
    // Fix poissible incorrect conversion in six argument
    if[6 in idxs; ptree[6]:ssr/[;("hopen";"hclose");("iasc";"idesc")] ptree 6];
    // Nested select statements
    if[-11<>type ptree 1; idxs,:1; ptree[1]:.z.s ptree 1];
    ptree:@[ptree;argIdxs except idxs;string];
    ptree[0],wrap["[";"]";] ";" sv 1_ptree
 };

// @brief Script entry point.
main:{[]
    query:first .z.x;
    if[0=count query; stderr usage; exit 1];
    stdout convertQuery parse query;
    exit 0;
 };

main[];
