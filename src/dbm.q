
/
    @file
        dbm.q
    
    @description
        Database maintenance utilities.

    @usage
        $q dbm.q

        or
        
        q)\l dbm.q
\

// @brief Add a column to a splayed table, in all partitions if DB is partitioned.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name (only required if column is symbol type).
// @param tname Symbol Table name.
// @param cname Symbol Column name.
// @param default Any Default value of the column.
.dbm.addCol:{[db;domain;tname;cname;default]
    .dbm.util.validateColName cname;
    default:.dbm.util.enum[db;domain;default];
    .dbm.util.add1Col[;cname;default] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief Apply a function to a table column.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
// @param fn Function Function to apply to column.
.dbm.fnCol:{[db;tname;cname;fn] 
    .dbm.util.fn1Col[;cname;fn] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief Cast a column to a given type.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
// @param typ Short|Char|Symbol Type to cast column to.
.dbm.castCol:{[db;tname;cname;typ] .dbm.fnCol[db;tname;cname;typ$];};

//@brief Set attribute on a column.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
// @param attrb Symbol Attribute (s, u, p, or g).     
.dbm.setAttr:{[db;tname;cname;attrb] .dbm.fnCol[db;tname;cname;attrb#];};

// @brief Remove attribute from a column.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
.dbm.rmAttr:{[db;tname;cname] .dbm.setAttr[db;tname;cname;`];};

// @brief Copy the data from an existing (old) column in a table to a new column.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param old Symbol Column name whose data will be copied.
// @param new Symbol New column name that will be created.
.dbm.copyCol:{[db;tname;old;new] 
    .dbm.util.validateColName new;
    .dbm.util.copy1Col[;old;new] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief Delete a column from a table.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
.dbm.delCol:{[db;tname;cname] .dbm.util.del1Col[;cname] peach .dbm.util.allTablePaths[db;tname];};

// @brief Does the given column exist in the table.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param cname Symbol Column name.
// @return Boolean 1b if the column exists within the table, 0b otherwise.
.dbm.hasCol:{[db;tname;cname] 
    all .dbm.util.has1Col[;cname] peach .dbm.util.allTablePaths[db;tname]
 };

// @brief Rename a column.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param old Symbol Current column name.
// @param new Symbol New column name.
.dbm.renameCol:{[db;tname;old;new] 
    .dbm.util.validateColName new;
    .dbm.util.rename1Col[;old;new] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief List all column names of the given table.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @return Symbols Column names.
.dbm.listCols:{[db;tname] .dbm.util.getColNames last .dbm.util.allTablePaths[db;tname]};

// @brief Reorder the columns in a given table.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param order Symbols New ordering of the columns.
.dbm.reorderCols:{[db;tname;order] 
    .dbm.util.reorderCols[;order] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief Add missing columns.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @param goodTable FileSymbol Path of a table directory which has no missing columns.
.dbm.addMissingCols:{[db;tname;goodTable]
    .dbm.util.addMissingCols[;goodTable] peach .dbm.util.allTablePaths[db;tname] except goodTable;
 };

// @brief Add a new table to all partitions.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name.
// @param tname Symbol New table name.
// @param schema Table New table schema.
.dbm.addTab:{[db;domain;tname;schema] 
    .dbm.util.add1Tab[db;domain;;schema] peach .dbm.util.allTablePaths[db;tname];
 };

// @brief Rename a table in all partitions.
// @param db FileSymbol Path to database root.
// @param old Symbol Current table name.
// @param new Symbol New table name.
.dbm.renameTab:{[db;old;new] 
    .dbm.util.rename1Tab .' flip .dbm.util.allTablePaths[db;] each old,new;
 };

// try .[.dbm.util.rename1Tab;] peach flip .dbm.util.allTablePaths[db;] each old,new

// @brief Remove a table from all partitions.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
.dbm.removeTab:{[db;tname] .dbm.util.rmTableDir peach .dbm.util.allTablePaths[db;tname];};


// @brief Add a column to a splayed table.
// @param tdir FileSymbol Table directory.
// @param cname Symbol Column name.
// @param default Any Default value of the column.
.dbm.util.add1Col:{[tdir;cname;default]
    if[not cname in colNames:.dbm.util.getColNames tdir;
        .dbm.util.logInfo " " sv (
            "Adding column";
            string cname;
            "(type ",(string type default),") to";
            1_string tdir
        );
        len:count get .Q.dd[tdir;first colNames];
        .[.Q.dd[tdir;cname];();:;len#default];
        @[tdir;`.d;,;cname]
    ]
 };

// @brief Apply a function to a table column.
// @param tdir FileSymbol Table directory.
// @param cname Symbol Column name.
// @param fn Function Function to apply to column.
.dbm.util.fn1Col:{[tdir;cname;fn]
    if[cname in .dbm.util.getColNames tdir;
        oldAttr:attr oldVal:get tdir,cname;
        newAttr:attr newVal:fn oldVal;
        if[$[oldAttr~newAttr;not oldVal~newVal;1b];
            .dbm.util.logInfo " " sv (
                "Saving column";
                string cname;
                "(type ",(string type newVal),") to";
                1_string tdir
            );
            oldVal:0; // Allow memory to be reclaimed if needed
            .[.Q.dd[tdir;cname];();:;newVal]
        ]
    ]
 };

// @brief Copy the data from an existing (old) column in a table to a new column.
// @param tdir FileSymbol Table directory.
// @param old Symbol Column name whose data will be copied. 
// @param new Symbol New column name that will be created.
.dbm.util.copy1Col:{[tdir;old;new]
    if[(old in colNames) and not new in colNames:.dbm.util.getColNames tdir;
        .dbm.util.logInfo " " sv (
            "Copying column"; string old; "to"; string new; "in"; 1_string tdir
        );
        .dbm.util.copy . .Q.dd[tdir;] each old,new;
        @[tdir;`.d;,;new]
    ]
 };

// @brief Delete a column from a table.
// @param tdir FileSymbol Table directory.
// @param cname Symbol Name of column to be deleted.
.dbm.util.del1Col:{[tdir;cname]
    if[cname in colNames:.dbm.util.getColNames tdir;
        .dbm.util.logInfo " " sv ("Deleting column"; string cname; "from"; 1_string tdir);
        hdel .Q.dd[tdir;cname];
        @[tdir;`.d;:;colNames except cname]
    ]
 };

// @brief Does the given column exist in the table.
// @param tdir FileSymbol Table directory.
// @param cname Symbol Column name.
// @return Boolean 1b if the column exists within the table, 0b otherwise.
.dbm.util.has1Col:{[tdir;cname] cname in .dbm.util.getColNames tdir};

// @brief Rename a column.
// @param tdir FileSymbol Table directory.
// @param old Symbol Current column name.
// @param new Symbol New column name.
.dbm.util.rename1Col:{[tdir;old;new]
    if[(old in c) and not new in colNames:.dbm.util.getColNames tdir;
        .dbm.util.logInfo " " sv (
            "Renaming column"; string old; "to"; string new; "in"; 1_string tdir
        );
        .dbm.util.rename . .Q.dd[tdir;] each old,new;
        @[tdir;`.d;:;.[colNames;where colNames=old;:;new]]
    ]
 };

// @brief Reorder the columns in a given table.
// @param tdir FileSymbol Table directory.
// @param order Symbols New ordering of the columns.
.dbm.util.reorderCols:{[tdir;order]
    if[not all b:order in colNames:.dbm.util.getColNames tdir;
        '.dbm.util.logError "No such column(s): ","," sv string order where b
    ];
    if[count colNames:colNames except order;
        '.dbm.util.logError "Missing column(s): ","," sv string colNames
    ];
    .dbm.util.logInfo "Reordering columns in ",1_string tdir;
    @[tdir;`.d;:;order];
 };

// @brief Add missing columns.
// @param tdir FileSymbol Table directory.
// @param goodTable FileSymbol Path of a table directory which has no missing columns.
.dbm.util.addMissingCols:{[tdir;goodTable]
    if[count missing:.dbm.util.getColNames[goodTable] except .dbm.util.getColNames tdir;
        .dbm.util.logInfo "Adding missing columns in ",1_string tdir;
        {[tdir;goodTable;tname] 
            .dbm.util.add1Col[tdir;tname;0#get goodTable,tname]
        }[tdir;goodTable;] each missing
    ]
 };

// @param Add a new table to a partition.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name.
// @param tdir FileSymbol New table directory.
// @param schema Table New table schema.
.dbm.util.add1Tab:{[db;domain;tdir;sch]
    .dbm.util.logInfo "Adding ",1_string tdir;
    @[tdir;`;:;.Q.ens[db;0#schema;domain]];
 };

// @brief Rename a table.
// @param old FileSymbol Path to current table within a partition.
// @param new FileSymbol Path to new table within a partition.
.dbm.util.rename1Tab:{[old;new]
    .dbm.util.logInfo " " sv ("Renaming"; 1_string old; "to"; 1_string new);
    .dbm.util.rename[old;new];
 };


// @brief Log info/errors. Redefine as (::) to turn off logging.
// @param x String Message to log.
// @return String Given message.
.dbm.util.logInfo:{-1 string[.z.P]," [INFO]: ",x; x};
.dbm.util.logError:{-2 string[.z.P]," [ERROR]: ",x; x};

// @brief Check whether a given column name is valid (adheres to proper naming rules). Signal error
// if not.
// @param cname Symbol Column name to validate.
.dbm.util.validateColName:{[cname]
    if[not .dbm.util.isValidName cname; '.dbm.util.logError "Invalid column name: ",string cname];
 };

// @brief Check whether a given name is valid (adheres to proper naming rules).
// @param name Symbol Name to check.
// @return Boolean 1b if valid, 0b otherwise.
.dbm.util.isValidName:{[name] (name=.Q.id name) and not name in `i,.Q.res,key`.q};

// @brief Get all paths to a table within a database.
// @param db FileSymbol Path to database root.
// @param tname Symbol Table name.
// @return FileSymbols List of paths to table within database.
.dbm.util.allTablePaths:{[db;tname]
    if[0=count files:key db; :`$()];
    if[any files like "par.txt"; :raze (.z.s[;t] hsym@) each `$read0 .Q.dd[db;`par.txt]];
    files@:where files like "[0-9]*";
    paths:$[count files; (.Q.dd[db;] ,[;tname]@) each files; enlist .Q.dd[db;tname]];
    paths where 0<(count key@) each paths
 };

// @brief Enumerate symbol values.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name.
// @param vals Any Values to enumerate (simply returned if not symbols).
.dbm.util.enum:{[db;domain;vals] $[11h=abs type vals; .Q.dd[db;domain]?vals; vals]};

// @brief Get all column names from a splayed table.
// @param tdir FileSymbol Table directory.
// @return Symbols Column names (empty if tdir does not exist).
.dbm.util.getColNames:{[tdir] $[count key .Q.dd[tdir;`.d]; get tdir,`.d; `$()]};

// @brief Delete a table directory and its contents.
// @param tdir FileSymbol Table directory to delete.
.dbm.util.rmTableDir:{[tdir] hdel each key tdir; hdel tdir};

.dbm.util.isWindows:.z.o in`w32`w64;

// @brief Convert a given file path into its string form, with correct path separators for the OS.
// @param path FileSymbol|Symbol|String File path to convert.
// @return String Converted file path.
.dbm.util.convertPath:{[path]
    path:$[10h=type path; path; string path];
    if[.dbm.util.isWindows; path[where"/"=path]:"\\"];
    (":"=first path)_ path
 };

// @brief Copy a source file to a destination file.
// @param src FileSymbol|Symbol|String File to copy.
// @param dst FileSymbol|Symbol|String Location to copy to.
.dbm.util.copy:{[src;dst]
    system $[.dbm.util.isWindows; "copy /v /z "; "cp "]," " sv .dbm.util.convertPath each (src;dst);
 };

// @brief Copy a source file to a destination file.
// @param src FileSymbol|Symbol|String File to copy.
// @param dst FileSymbol|Symbol|String Location to copy to.
.dbm.util.rename:{[src;dst] system "r "," " sv .dbm.util.convertPath each (src;dst);};



/

splayDB:`:/home/jkane17/repos/WIP/q/qschool/testSplayDB;
partDB:`:/home/jkane17/repos/WIP/q/qschool/testPartDB;


.dbm.util.isValidName
.dbm.util.allTablePaths[`:testSplayDB;`trade]
.dbm.util.enum
.dbm.util.getColNames

.dbm.addCol[`:testSplayDB;`;`trade;`newCol;10]
.dbm.addCol[`:testSplayDB;`sym;`trade;`newSymCol;`ABC]

.dbm.fnCol[`:testSplayDB;`trade;`price;2*]

.dbm.castCol[`:testSplayDB;`trade;`time;`second]

.dbm.setAttr[`:testSplayDB;`trade;`sym;`p]

.dbm.rmAttr[`:testSplayDB;`trade;`sym]

.dbm.copyCol[`:testSplayDB;`trade;`size;`size2]

.dbm.delCol[`:testSplayDB;`trade;`iz]

.dbm.hasCol[`:testSplayDB;`trade;`iz]

.dbm.renameCol[`:testSplayDB;`trade;`price;`PRICE]

.dbm.listCols[`:testSplayDB;`trade]    

.dbm.reorderCols[`:testSplayDB;`trade;reverse cols trade]     

.dbm.addMissingCols[`:testSplayDB;`trade;`:testSplayDB/2023.12.29/trade]

.dbm.addTab[`:testSplayDB;`trade;([] sym:`a`b`c; price:1 2 3)]

.dbm.removeTab[`:testSplayDB;`trade]
