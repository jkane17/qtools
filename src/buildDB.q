
/
    @file
        buildDB.q
    
    @description
        Create a dummy splayed or partitioned database.

    @usage
        $q buildDB.q [OPTIONS]

        |   Option  |                                    Description                                    |        Default        |
        | --------- | --------------------------------------------------------------------------------- | --------------------- |
        | root      | Path where root will be created. Must be an empty directory.                      | PWD                   |
        | domain    | Sym file (domain) name.                                                           | sym                   |
        | dbtype    | The type of database (splay or part).                                             | splay                 |  
        | ptype     | Partion type (date, month, year, or int).                                         | date                  |
        | nparts    | Number of partions to create (overwritten if partstart & partend provided).       | 1                     |
        | partstart | First partition (e.g., 2025.01.01, 2025.01m, 1).                                  | (TODAY - nparts) or 1 |
        | partend   | Last partition (e.g., 2025.12.31, 2025.12m, 10).                                  | TODAY or nparts       |
        | ntabs     | Number of tables per partition.                                                   | 1                     |
        | nrows     | Number of rows per table.                                                         | 1                     |
        | ncols     | Number of cols per table.                                                         | 1                     |
        | nsymcols  | Number of sym cols per table.                                                     | 0                     |
        | nsyms     | Max number of distinct symbols (may be lower depending on ntabs, ncols, & nrows). | 100                   |

    @todo
        - Allow config option for finer grain control of table/column names, column types, and how random values are generated.
\

stdout:-1;
stderr:-2;

// Command line option defaults
defaults:(!). flip 2 cut (
    `root;      `:.;
    `domain;    `sym;
    `dbtype;    `splay;
    `ptype;     `date;
    `nparts;    1;
    `partstart; enlist "";
    `partend;   enlist "";
    `ntabs;     1;
    `nrows;     1;
    `ncols;     1;
    `nsymcols;  0;
    `nsyms;     100
 );

// Random value generators
randf:("c"$())!();
randf["b"]:?[;0b];
randf["g"]:?[;0Ng];
randf["x"]:?[;0x0];
randf["hij"]:?[;100];
randf["ef"]:{?[x;1000]%10};
randf["c"]:?[;.Q.nA];
randf["s"]:?[;`8];
randf["pmdznuvt"]:?[;.z.p];

// @brief Script entry point.
main:{[]
    st:.z.p;

    opts:parseOpts[];

    dbtype:opts`dbtype;
    stdout "Creating ",$[`splay=dbtype;"splayed";"partioned"]," database: ",1_string opts`root;

    $[`splay=dbtype; createSplayed; createParted] opts;

    stdout "Database created";
    stdout "Time taken: ",.Q.f[3;1e-9*.z.p-st]," seconds";
    stdout "Disk usage of database: ",(reverse "," sv 3 cut reverse string diskUsage opts`root)," bytes";

    exit 0;
 };

// @brief Parse command line options.
// @return Dict Command line options.
parseOpts:{[]
    opts:.Q.def[defaults;] .Q.opt .z.x;

    opts[`root]:hsym opts`root;

    // Validate opts
    if[count key opts`root; stderr "Root must be empty"; exit 1];
    if[not opts[`dbtype] in `splay`part; stderr "dbtype must be splay or part"; exit 1];
    if[not opts[`ptype] in `date`month`year`int; stderr "ptype must be date, month, year, or int"; exit 1];
    gtz each opts`ntabs`ncols;
    gtez each opts`nparts`nrows`nsymcols`nsyms;
    if[(>). opts`nsymcols`ncols; stderr "nsymcols must not be greater than ncols"; exit 1];

    // Set partstart and partend
    ptype:opts`ptype;
    cast:(`date`month`year`int!"DMJJ") ptype;
    opts[`partstart]:cast$first opts`partstart;
    opts[`partend]:cast$first opts`partend;
    if[null opts`partend; 
        opts[`partend]:$[null opts`partstart;
            @[;ptype] `date`month`year`int!(.z.d;`month$.z.d;`year$.z.d;opts`nparts);
            -1+opts[`partstart]+opts`nparts
        ]
    ];
    if[null opts`partstart; opts[`partstart]:1+opts[`partend]-opts`nparts];
    if[(>). opts`partstart`partend; "partstart must not be greater than partend"; exit 1];

    opts
 };

// @brief Validate greater than zero.
// @param Long|Int|Short Value to validate.
gtz:{if[1>x; stderr string[x]," must greater than zero"; exit 1]};

// @brief Validate greater than or equal to zero.
// @param Long|Int|Short Value to validate.
gtez:{if[0>x; stderr string[x]," must greater than or equal to zero"; exit 1]};

// @brief Create a splayed DB.
// @param opts Dict Command line options.
createSplayed:{[opts]
    syms:genSyms . opts`ntabs`nrows`nsymcols`nsyms;
    tabs:genData[opts`nrows;syms;] each createSchema . opts`ntabs`ncols`nsymcols;
    splay'[opts`root;opts`domain;key tabs;value tabs];
 };

// @brief Generate symbol values.
// @param ntabs Long Number of tables.
// @param nrows Long Number of rows per table.
// @param nsymcols Long Number of symbol type columns per table.
// @param nsyms Long Max number of distinct symbol values.
// @return Symbols Symbol values.
genSyms:{[ntabs;nrows;nsymcols;maxsyms] randf["s"] neg min (ntabs*nrows*nsymcols;maxsyms)};

// @brief Create table schema.
// @param ntabs Long Number of tables.
// @param ncols Long Number of columns per table.
// @param nsymcols Long Number of symbol type columns per table.
// @return Dict Mapping of table name to its schema.
createSchema:{[ntabs;ncols;nsymcols] genNames["t";ntabs]!genSchema[ntabs;ncols;nsymcols]};

// @brief Generate schema.
// @param ntabs Long Number of tables.
// @param ncols Long Number of columns per table.
// @param nsymcols Long Number of symbol type columns per table.
genSchema:{[ntabs;ncols;nsymcols] 
    1_ ntabs {[nc;nsc;n;x] flip n!genTypes[nc;nsc]$\:()}[ncols;nsymcols;genNames["c";ncols];]\()
 };

// @brief Generate datatypes.
// @param ncols Long Number of columns per table.
// @param nsymcols Long Number of symbol type columns per table.
// @return String Datatypes.
genTypes:{[ncols;nsymcols] neg[ncols]??[ncols-nsymcols;"bgxhijefcpmdznuvt*"],nsymcols#"s"};

// @brief Generate a list of name1, name2, ..., nameN.
// @param name Symbol Base name.
// @param n Long|Int|Short Max number.
// @return Symbols List of generated names.
genNames:{[name;n] `$string[name],/:string 1+til n};

// @brief Generate n random values.
// @param n Long Number of values to generate.
// @param typ Char Datatype.
// @return Any Random values.
genRand:{[n;typ] $[" "=typ; (); typ$randf[typ] n]};

// @brief Generate table data.
// @param nrows Long Number of rows in table.
// @param syms Symbols Distinct symbol pool to draw from.
// @param schema Table Schema.
// @return Table data. 
genData:{[nrows;syms;schema]
    types:exec t from meta schema;
    symCols:where types="s";
    types:@[types;symCols;:;" "];
    data:genRand[nrows;] each types;
    if[count symCols; 
        data:{[n;s;d;i] @[d;i;:;n?s]}[nrows;syms;;]/[data;symCols];
        types:@[types;symCols;:;"s"]
    ];
    if[c:count i:where types=" ";
        data:@/[data;i;:;nrows cut randf["c";] each raze nrows#enlist c#nrows]
    ]; 
    schema upsert flip data 
 };

// @brief Splay a table to a database, enumerated against a given domain.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name. 
// @param tname Symbol Table name.
// @param data Table Table data.
// @return FileSymbol Relative path to splayed table.
splay:{[db;domain;tname;data] .Q.dd[db;tname,`] set .Q.ens[db;data;domain]};

// @brief Create a partitioned DB.
// @param opts Dict Command line options.
createParted:{[opts]
    parts:opts[`partstart]+til 1+opts[`partend]-opts`partstart;
    schema:createSchema . opts`ntabs`ncols`nsymcols;
    syms:genSyms . opts`ntabs`nrows`nsymcols`nsyms;
    createPart[opts`root;opts`domain;schema;opts`nrows;syms;] each parts;
 };

// @brief Create a single partition.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name. 
// @param schema Table Schema.
// @param nrows Long Number of rows per table.
// @param syms Symbols Distinct symbol pool to draw from.
// @param part Integral Partition.
createPart:{[db;domain;schema;nrows;syms;part] 
    partition[db;domain;part;] genData[nrows;syms;] each schema;
 };

// @brief Create a partition in a database, enumerated against a domain.
// @param db FileSymbol Path to database root.
// @param domain Symbol Sym file (domain) name. 
// @param part Integral Partition.
// @param td Dict Mapping of table name to data.
partition:{[db;domain;part;td]
    tnames:(`$"/" sv string part,) each key td;
    splay'[db;domain;tnames;value td];
 };

// @brief Get the disk usage of a given DB.
// @param db FileSymbol Database root.
// @return Long Size of DB in bytes.
diskUsage:{[db] sum hcount each allFiles db};

// @brief Recursively list all files under a given directory.
// @param dir FileSymbol Directory to list.
// @retrun FileSymbols All files.
allFiles:{[dir] $[11h=type f:key dir; raze (.z.s .Q.dd[dir;]@) each f; f]};

main[];
