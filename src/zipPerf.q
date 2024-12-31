
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
        Sudo priviliges are required. Password prompt will appear if applicable.
\

.zipPerf.cfg.ntimes:10;           // Number of times to read/write and then take average over
.zipPerf.cfg.tmpFile:`:./tmpData; // Temporary file where data will be read from/written to

.zipPerf.priv.levels:(1#0; 1#0; til 10; 1#0; til 17; -7+til 30);
.zipPerf.priv.lbs:12+til 9;

.zipPerf.priv.statsSchema:flip 
    `lbs`alg`lvl`dataType`dataCount`writeTime`readTime`compFactor`testTime!"jjjhjnnfn"$/:();

// @brief Clear the OS cache (Linux).
.zipPerf.priv.clearCache:{[] system "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"};

// @brief Delete a file.
// @param x FileSymbol File to be deleted.
.zipPerf.priv.del:@[hdel;;()];

// @brief Calculate the average run time of some operation.
// @param func GeneralList Function and its arguments. 
.zipPerf.priv.timeit:{[func]
    t:"n"$();
    do[.zipPerf.cfg.ntimes; t,:value func];
    "n"$avg t
 };

// @brief Time a (compressed data) write operation.
// @param params GeneralList Temporary file to write to and compression parameters.
// @param data Any Data to compress and write.
// @return Timespan Time taken to perform write operation.
.zipPerf.priv.timeWrite:{[params;data]
    .zipPerf.priv.del first params;
    .zipPerf.priv.clearCache[];
    st:.z.p;
    params set data;
    .z.p-st
 };

// @brief Time a (compressed data) read operation.
// @param File FileSymbol File to read.
// @return Timespan Time taken to perform read operation.
.zipPerf.priv.timeRead:{[file]
    .zipPerf.priv.clearCache[];
    st:.z.p;
    get file;
    .z.p-st
 };

// @brief Time a compressed table query.
// @param params GeneralList Temporary file to write to and compression parameters.
// @param query Function|String Query to apply (QSQL query as a string or functional form).
// @param table Table Data to compress and query.
// @return Timespan Time taken to perform read operation.
.zipPerf.priv.timeQuery:{[params;query;table]
    .zipPerf.priv.timeWrite[params;table];
    st:.z.p;
    query enlist first params;
    .z.p-st
 };

// @brief Compute the average write time of the data in compressed form.
// @param params GeneralList Temporary file to write to and compression parameters.
// @param data Any Data to compress and write.
// @return Timespan Average time taken to perform write operation.
.zipPerf.priv.avgWriteTime:{[params;data] 
    .zipPerf.priv.timeit (`.zipPerf.priv.timeWrite;params;data)
 };

// @brief Compute the average read time of the given file.
// @param File FileSymbol File to read.
// @return Timespan Average time taken to perform read operation.
.zipPerf.priv.avgReadTime:{[file] .zipPerf.priv.timeit (`.zipPerf.priv.timeRead;file)};

// @brief Compute the average query time of a compressed table.
// @param params GeneralList Temporary file to write to and compression parameters.
// @param query Function|String Query to apply (QSQL query as a string or functional form).
// @param table Table Data to compress and query.
// @return Timespan Average time taken to perform query.
.zipPerf.priv.avgQueryTime:{[params;query;table] 
    .zipPerf.priv.timeit (`.zipPerf.priv.timeQuery;params;query;table)
 };

// @brief Measure the compression read and write times for the given parameters and data.
// @param params GeneralList Temporary file to write to and compression parameters.
// @param data Any Data to compress.
// @return Dict Average write time, average read time, and compression factor.
.zipPerf.priv.measure:{[params;data]
    file:first params;
    wt:.zipPerf.priv.avgWriteTime[params;data];
    rt:.zipPerf.priv.timeRead file;
    f:.zipPerf.factor file;
    .zipPerf.priv.del file;
    `writeTime`readTime`compFactor!(wt;rt;f)
 };

// @brief Utility to remove all but one parameter set where alg = 0 (no compression)
// @param params GeneralList Compression parameter lists to filter.
// @return GeneralList Filtered compression parameter lists.
.zipPerf.priv.fltZeros:{[params] $[any i:0=params[;1]; enlist[0 0 0],params where not i; params]};

// @breif Build all combinations of algorithms and levels.
// @return GeneralList All algorithm-level combinations (list of two element lists). 
.zipPerf.priv.allAlgLvls:{[] raze (til count .zipPerf.priv.levels) cross'.zipPerf.priv.levels};

// @breif Build all combinations of compression parameters.
// @return GeneralList All LBS-algorithm-level combinations (list of three element lists). 
.zipPerf.priv.allCombs:{[] 
    .zipPerf.priv.fltZeros .zipPerf.priv.lbs cross .zipPerf.priv.allAlgLvls[]
 };

// @brief Compute the compression factor.
// @brief file FileSymbol File to compute compression factor for.
// @return Float Compression factor.
.zipPerf.factor:{[file] $[count s:-21!file; (%). s`uncompressedLength`compressedLength; 0n]};

// @brief Test data compression for a single list of compression parameters.
// @param params Longs Compression parameters.
// @param data Any Data to test cmpression on.
// @return Dict Compression statistics.
.zipPerf.testSingle:{[params;data] 
    st:.z.p;
    stats:flip .zipPerf.priv.statsSchema;
    stats:stats upsert `lbs`alg`lvl!params;
    stats:stats upsert `dataType`dataCount!(type data;count data);
    stats:stats upsert .zipPerf.priv.measure[.zipPerf.cfg.tmpFile,params;data];
    stats[`testTime]:.z.p-st;
    stats  
 };

// @brief Test data compression for each given compression parameter list.
// @param params GeneralList List of compression parameter lists.
// @param data Any Data to test cmpression on.
// @return Table Compression statistics.
.zipPerf.testCompression:{[params;data] .zipPerf.testSingle[;data] each params};

// @brief Test data compression for a given (l)ogical (b)lock (s)torage value with all combinations 
// of algorithms and levels.
// @param lbs Long Logical block size.
// @param data Any Data to test cmpression on.
// @return Table Compression statistics.
.zipPerf.testLBS:{[lbs;data] 
    .zipPerf.testCompression[;data] 
        .zipPerf.priv.fltZeros[lbs,/:.zipPerf.priv.allAlgLvls[]] except enlist 0 0 0 
 };

// @brief Test data compression for a given (alg)orithm with all combinations of lbs values and 
// levels.
// @param alg Long Compression algorithm.
// @param data Any Data to test cmpression on.
// @return Table Compression statistics.
.zipPerf.testAlg:{[alg;data] 
    .zipPerf.testCompression[;data] 
        .zipPerf.priv.fltZeros .zipPerf.priv.lbs cross alg,/:.zipPerf.priv.levels alg
 };

// @brief Test data compression for all combinations of lbs, algorithms, and levels.
// @param data Any Data to test cmpression on.
// @return Table Compression statistics.
.zipPerf.testAll:{[data] .zipPerf.testCompression[;data] .zipPerf.priv.allCombs[]};

// @brief Test a query on a compressed table.
// @params Compression parameters in the form (LBS;algorithm;level).
// @param query Function|String Query to apply. Can be a QSQL query as a string (table name does not
// matter as it is replaced). Otherwise, query functional form with first param (table) missing.
// @param table Table Table data to test.
// @return Dict Query statistics.
.zipPerf.testQuery:{[params;query;table]
    st:.z.p;
    stats:flip `lbs`alg`lvl`dataCount`testTime#.zipPerf.priv.statsSchema;
    stats:stats upsert `lbs`alg`lvl`dataCount!params,count table;
    if[10h=type query; query:eval @[parse query;1;:;]@];
    stats[`queryTime]:.zipPerf.priv.avgQueryTime[.zipPerf.cfg.tmpFile,params;query;table];
    .zipPerf.priv.del .zipPerf.cfg.tmpFile;
    stats[`testTime]:.z.p-st;
    stats 
 };

// @brief Test a query on a compressed table for all compression parameter combinations.
// @param query Function|String Query to apply. Can be a QSQL query as a string (table name does not
// matter as it is replaced). Otherwise, query functional form with first param (table) missing.
// @param table Table Table data to test.
// @return Table Query statistics.
.zipPerf.testQueryAll:{[query;table]
    .zipPerf.testQuery[;query;table] each .zipPerf.priv.allCombs[]
 };
