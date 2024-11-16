
/
    File:
        zipPerf.q
    
    Description:
        Test the performance of difference zip parameters for the given data.
    
    Supported OS:
        Linux

    Usage:
        $q zipPerf.q

        or
        
        q)\l zipPerf.q

    Note:
        Sudo priviliges are required. Password prompt will appear if applicable
\

.zipPerf.cfg.ntimes:10;           // Number of times to read/write and then take average over
.zipPerf.cfg.tmpFile:`:./tmpData; // Temporary file where data will be read from/written to

.zipPerf.priv.levels:(1#0; 1#0; til 10; 1#0; til 17; -7+til 30);
.zipPerf.priv.lbs:12+til 9;

.zipPerf.priv.statsSchema:flip 
    `lbs`alg`lvl`dataType`dataCount`writeTime`readTime`compFactor`testTime!"jjjhjnnfn"$/:();

// Clear the OS cache
.zipPerf.priv.clearCache:{[] system "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"};

// Delete a file
.zipPerf.priv.del:@[hdel;;()];

// Compute the average write time of the data into compressed form
.zipPerf.priv.timeWrite:{[params;data]
    t:"n"$();
    do[.zipPerf.cfg.ntimes;
        .zipPerf.priv.del first params;
        .zipPerf.priv.clearCache[];
        st:.z.p;
        params set data;
        t,:.z.p-st
    ];
    "n"$avg t
 };

// Compute the average read time of the given file
.zipPerf.priv.timeRead:{[file]
    t:"n"$();
    do[.zipPerf.cfg.ntimes;
        .zipPerf.priv.clearCache[];
        st:.z.p;
        get file;
        t,:.z.p-st
    ];
    "n"$avg t
 };

// Measure the compression read and write times for the given parameters and data
.zipPerf.priv.measure:{[params;data]
    file:first params;
    wt:.zipPerf.priv.timeWrite[params;data];
    rt:.zipPerf.priv.timeRead file;
    f:.zipPerf.factor file;
    .zipPerf.priv.del file;
    `writeTime`readTime`compFactor!(wt;rt;f)
 };

// When alg = 0, no compression will be applied so remove redundant param lists 
// with alg = 0, and only keep 1
.zipPerf.priv.fltZeros:{[params] $[any i:0=params[;1]; enlist[0 0 0],params where not i; params]};

// Get all combinations of algorithms and levels
.zipPerf.priv.allAlgLvls:{[] raze (til count .zipPerf.priv.levels) cross'.zipPerf.priv.levels};

// Compute the compression factor
.zipPerf.factor:{[file] $[count s:-21!file; (%). s`uncompressedLength`compressedLength; 0n]};

// Test data compression for a single list of compression parameters
.zipPerf.testSingle:{[params;data] 
    st:.z.p;
    stats:flip .zipPerf.priv.statsSchema;
    stats:stats upsert `lbs`alg`lvl!params;
    stats:stats upsert `dataType`dataCount!(type data;count data);
    stats:stats upsert .zipPerf.priv.measure[.zipPerf.cfg.tmpFile,params;data];
    stats[`testTime]:.z.p-st;
    stats  
 };

// Test data compression for each given compression parameter list
.zipPerf.testCompression:{[params;data] .zipPerf.testSingle[;data] each params};

// Test data compression for a given (l)ogical (b)lock (s)torage value with all combinations of
// algorithms and levels
.zipPerf.testLBS:{[lbs;data] 
    .zipPerf.testCompression[;data] 
        .zipPerf.priv.fltZeros[lbs,/:.zipPerf.priv.allAlgLvls[]] except enlist 0 0 0 
 };

// Test data compression for a given (alg)orithm with all combinations of lbs values and levels
.zipPerf.testAlg:{[alg;data] 
    .zipPerf.testCompression[;data] 
        .zipPerf.priv.fltZeros .zipPerf.priv.lbs cross alg,/:.zipPerf.priv.levels alg
 };

// Test data compression for all combinations of lbs, algorithms, and levels
.zipPerf.testAll:{[data] 
    .zipPerf.testCompression[;data] 
        .zipPerf.priv.fltZeros .zipPerf.priv.lbs cross .zipPerf.priv.allAlgLvls[]
 };
