
# Measure Compression Performance

Functions to measure the compression performance of some given data.

## Important Notes

* This tool is only supported on Linux currently.

* The cache is cleared between reads and writes. This may cause some issues on your OS whilst the test is running, such as screen flickering. It would be best to run this in an isolated environment where the cache clearing will not affect other important processes.

## Loading

The script can be loaded into a Q session on startup:

```bash
$q zipPerf.q
```

or it can be loaded into a running Q session:

```q
q)\l zipPerf.q
```

## Configuration

### ntimes

Measurements are taken some number of times specified by the variable `.zipPerf.cfg.ntimes`. The result is the average of these measurements. This is because a single measurement may be skewed by some uncontrollable system related factor. By averaging over a few measurements, we get a better estimate.

The default value of `.zipPerf.cfg.ntimes` is 5. This can be changed simply by setting this varaible before running the test:

```q
q).zipPerf.cfg.ntimes:20
```

### tmpFile

During the test, data is written and read from a temporary file which will (should) be cleaned up afterwards.

By default, this file is stored in the current working directory.  This can be changed incase of permissioning issues or to test compression on different mounts for example.

```q
.zipPerf.cfg.tmpFile:`:/path/to/tmpData
```

## Test Functions

Below is a description the functions provided. For each function, an example is provided where I have used:

```q
data:1000?100
```

### testSingle

Test data compression for a single list of compression parameters.

```q
.zipPerf.testSingle[params;data] 
```

* `params` - Compression paramters of the form `lbs alg lvl`.
* `data` - Data to compress.

#### Example - Compression with LBS = 16 and using the GZip algorithm at level 0

```q
q).zipPerf.testSingle[16 2 0;data]
lbs       | 16
alg       | 2
lvl       | 0
dataType  | 7h
dataCount | 1000
writeTime | 0D00:00:00.000228319
readTime  | 0D00:00:00.000811178
compFactor| 0.9930624
testTime  | 0D00:00:01.737507018
```

The return value contains information about the compression parameters, the type and count of our data, as well as the compression measurements. In this example (approximately) the average write time was 228 microseconds, the average read time was 811 microseconds, the compression factor was 0.993, and the time taken to run the test was 1.738 seconds.

### testCompression

Test data compression for each given compression parameter list.

```q
.zipPerf.testCompression[params;data] 
```

* `params` - A list of different compression paramters of the form `(lbs alg lvl;lbs alg lvl;...)`.
* `data` - Data to compress.

#### Example - Compression with LBS = 16 and using the GZip algorithm for all possible levels

The GZip algorithm has 10 possible leves (0 - 9). To generate a list of all possible parameter combinations (with LBS = 16), use the following:

```q
q)(cross/)(16;2;til 10)
16 2 0
16 2 1
16 2 2
16 2 3
16 2 4
16 2 5
16 2 6
16 2 7
16 2 8
16 2 9
```

The `testCompression` function can now be used to test the given parameter combinations:

```q
q).zipPerf.testCompression[;data] (cross/)(16;2;til 10)
lbs alg lvl dataType dataCount writeTime            readTime             compFactor testTime            
--------------------------------------------------------------------------------------------------------
16  2   0   7        1000      0D00:00:00.000212533 0D00:00:00.000717722 0.9930624  0D00:00:02.135759061
16  2   1   7        1000      0D00:00:00.000280080 0D00:00:00.001083678 4.541643   0D00:00:01.914860124
16  2   2   7        1000      0D00:00:00.000310790 0D00:00:00.000664323 4.731995   0D00:00:01.613706726
16  2   3   7        1000      0D00:00:00.000289890 0D00:00:00.000768963 4.834741   0D00:00:01.630347271
16  2   4   7        1000      0D00:00:00.000350366 0D00:00:00.000853975 4.861128   0D00:00:01.635559534
16  2   5   7        1000      0D00:00:00.000379570 0D00:00:00.000989886 4.890787   0D00:00:02.064625372
16  2   6   7        1000      0D00:00:00.000507038 0D00:00:00.000857622 4.923833   0D00:00:02.017642527
16  2   7   7        1000      0D00:00:00.000483473 0D00:00:00.000826573 4.926859   0D00:00:01.553338931
16  2   8   7        1000      0D00:00:00.002187836 0D00:00:00.000727414 5.383479   0D00:00:01.967717640
16  2   9   7        1000      0D00:00:00.005497394 0D00:00:00.000906904 5.456773   0D00:00:01.835944515
```

The return value is a table where each row corresponds to the compression measurements of each of the given input parameter lists.

### testLBS

Test data compression for a given logical block storage value with all combinations of algorithms and levels.

```q
.zipPerf.testLBS[lbs;data]
```

* `lbs` - LBS value.
* `data` - Data to compress.

#### Example - Compression with LBS = 16 and all algorithm and level combinations

```q
q).zipPerf.testLBS[16;data]
lbs alg lvl dataType dataCount writeTime            readTime             compFactor testTime            
--------------------------------------------------------------------------------------------------------
16  1   0   7        1000      0D00:00:00.000167243 0D00:00:00.000647975 3.476149   0D00:00:01.329662790
16  2   0   7        1000      0D00:00:00.000089953 0D00:00:00.000593731 0.9930624  0D00:00:01.217281612
16  2   1   7        1000      0D00:00:00.000156720 0D00:00:00.000586067 4.526256   0D00:00:01.204517561
16  2   2   7        1000      0D00:00:00.000173682 0D00:00:00.000646355 4.676779   0D00:00:01.210335529
16  2   3   7        1000      0D00:00:00.000233244 0D00:00:00.000647230 4.802876   0D00:00:01.385352720
..
```

The return value is a table where each row corresponds to the compression measurements of the given LBS value and some algorithm-level combination.

### testAlg

Test data compression for a given algorithm with all combinations of LBS values and levels.

```q
.zipPerf.testAlg[alg;data]
```

* `alg` - Compression aslgorithm.
* `data` - Data to compress.

#### Example - Compression using the GZip algorithm with all possible LBS and level combinations

```q
q).zipPerf.testAlg[2;data]
lbs alg lvl dataType dataCount writeTime            readTime             compFactor testTime            
--------------------------------------------------------------------------------------------------------
12  2   0   7        1000      0D00:00:00.000178080 0D00:00:00.000601219 0.9920792  0D00:00:01.200752208
12  2   1   7        1000      0D00:00:00.000210612 0D00:00:00.000599695 4.368392   0D00:00:01.477384970
12  2   2   7        1000      0D00:00:00.000180618 0D00:00:00.000547559 4.465738   0D00:00:01.206231951
12  2   3   7        1000      0D00:00:00.000217310 0D00:00:00.000615517 4.518602   0D00:00:01.216580901
12  2   4   7        1000      0D00:00:00.000223567 0D00:00:00.000556481 4.695958   0D00:00:01.199417898
12  2   5   7        1000      0D00:00:00.000240039 0D00:00:00.000713552 4.69871    0D00:00:01.240112888
12  2   6   7        1000      0D00:00:00.000331451 0D00:00:00.000710993 4.671329   0D00:00:01.252586401
12  2   7   7        1000      0D00:00:00.000446107 0D00:00:00.000622234 4.704225   0D00:00:01.253378963
12  2   8   7        1000      0D00:00:00.001666284 0D00:00:00.000714435 5.089524   0D00:00:01.237120438
12  2   9   7        1000      0D00:00:00.002597384 0D00:00:00.000608166 5.122045   0D00:00:01.414150084
13  2   0   7        1000      0D00:00:00.000113854 0D00:00:00.000527894 0.9930624  0D00:00:01.261016637
13  2   1   7        1000      0D00:00:00.000168938 0D00:00:00.000562819 4.526256   0D00:00:01.272122935
..
```

The return value is a table where each row corresponds to the compression measurements of the given algorithm and some LBS-level combination.

### testAll

Test data compression for all combinations of LBS, algorithms, and levels.

```q
.zipPerf.testAll data
```

* `data` - Data to compress.

#### Example - Compression with all possible LBS, algorithm, and level combinations

```q
q).zipPerf.testAll data
lbs alg lvl dataType dataCount writeTime            readTime             compFactor testTime            
--------------------------------------------------------------------------------------------------------
0   0   0   7        1000      0D00:00:00.000155541 0D00:00:00.000597738            0D00:00:01.403208987
12  1   0   7        1000      0D00:00:00.000121145 0D00:00:00.000497359 3.023765   0D00:00:01.330510457
12  2   0   7        1000      0D00:00:00.000102733 0D00:00:00.000644769 0.9920792  0D00:00:01.265026026
12  2   1   7        1000      0D00:00:00.000178911 0D00:00:00.000610454 4.368392   0D00:00:01.258246259
12  2   2   7        1000      0D00:00:00.000206562 0D00:00:00.000608850 4.465738   0D00:00:01.278474703
12  2   3   7        1000      0D00:00:00.000204067 0D00:00:00.000593294 4.518602   0D00:00:01.216283735
12  2   4   7        1000      0D00:00:00.000223618 0D00:00:00.000531869 4.695958   0D00:00:01.203847254
12  2   5   7        1000      0D00:00:00.000250969 0D00:00:00.000542795 4.69871    0D00:00:01.232474395
12  2   6   7        1000      0D00:00:00.000341277 0D00:00:00.000514871 4.671329   0D00:00:01.200566169
12  2   7   7        1000      0D00:00:00.000507569 0D00:00:00.000712314 4.704225   0D00:00:01.400099316
12  2   8   7        1000      0D00:00:00.001690548 0D00:00:00.000558142 5.089524   0D00:00:01.241570061
12  2   9   7        1000      0D00:00:00.002430610 0D00:00:00.000624220 5.122045   0D00:00:01.318928950
12  3   0   7        1000      0D00:00:00.000100817 0D00:00:00.000616533 3.168379   0D00:00:01.405512126
12  4   0   7        1000      0D00:00:00.000324746 0D00:00:00.000642972 3.497382   0D00:00:01.212570766
12  4   1   7        1000      0D00:00:00.000155836 0D00:00:00.000579983 3.208967   0D00:00:01.233334779
12  4   2   7        1000      0D00:00:00.000145223 0D00:00:00.000541235 3.208967   0D00:00:01.195157587
..
```

The return value is a table where each row corresponds to the compression measurements of some LBS-algorithm-level combination.

### testAllRand

Run testAll multiple times for different random data and take an average of the results.

This is useful if you want to find the best parameter combination in general as the test is run for different random lists.

```q
.zipPerf.testAllRand[n;gf]
```

* `n` - Number of times to run.
* `gf` - Generator function to create random data.

#### Example - Compression with all possible LBS, algorithm, and level combinations for random lists of longs

```q
q).zipPerf.testAllRand[10;{1000?100}]
lbs alg lvl dataType dataCount writeTime            readTime             compFactor testTime            
--------------------------------------------------------------------------------------------------------
0   0   0   7        1000      0D00:00:00.000077714 0D00:00:00.000187332            0D00:00:04.715395829
12  1   0   7        1000      0D00:00:00.000105548 0D00:00:00.000173705 3.166576   0D00:00:04.970611999
12  2   0   7        1000      0D00:00:00.000102829 0D00:00:00.000150098 0.9920792  0D00:00:04.785179199
12  2   1   7        1000      0D00:00:00.000190296 0D00:00:00.000243727 4.385968   0D00:00:04.867883235
12  2   2   7        1000      0D00:00:00.000194442 0D00:00:00.000246453 4.502704   0D00:00:04.846590898
12  2   3   7        1000      0D00:00:00.000214193 0D00:00:00.000182812 4.538073   0D00:00:04.797689885
12  2   4   7        1000      0D00:00:00.000223326 0D00:00:00.000224947 4.725345   0D00:00:04.876100725
12  2   5   7        1000      0D00:00:00.000266821 0D00:00:00.000333538 4.699654   0D00:00:04.966641278
12  2   6   7        1000      0D00:00:00.000372714 0D00:00:00.000279373 4.68675    0D00:00:05.112665167
12  2   7   7        1000      0D00:00:00.000462963 0D00:00:00.000252609 4.723701   0D00:00:05.130355051
12  2   8   7        1000      0D00:00:00.001729437 0D00:00:00.000254381 5.102836   0D00:00:05.274273416
12  2   9   7        1000      0D00:00:00.002567057 0D00:00:00.000267353 5.122102   0D00:00:05.342428371
12  3   0   7        1000      0D00:00:00.000123172 0D00:00:00.000254917 3.193653   0D00:00:05.216694103
12  4   0   7        1000      0D00:00:00.000377069 0D00:00:00.000158438 3.490863   0D00:00:05.491385262
12  4   1   7        1000      0D00:00:00.000155222 0D00:00:00.000241541 3.20796    0D00:00:04.999821601
12  4   2   7        1000      0D00:00:00.000164817 0D00:00:00.000226271 3.20796    0D00:00:05.308271308
..
```

The return value is a table where each row corresponds to the compression measurements of some LBS-algorithm-level combination.

The `writeTime`, `readTime`, and `compFactor` columns are the **average** over all the different random lists. 

The `testTime` column is the **sum** of the times taken for each test.

### testQuery

Test a query on a compressed table.

```q
.zipPerf.testQuery[params;query;table]
```

* `params` - A list of different compression paramters of the form `(lbs alg lvl;lbs alg lvl;...)`.
* `query` - Query to apply. Can be a QSQL query as a string (table name does not matter as it is replaced). Otherwise, query functional form with first param (table) missing.
* `table` - Table data to test.

#### Example - Compression with all possible LBS, algorithm, and level combinations

```q
q).zipPerf.testQuery[17 2 0;"select avg price by sym from t";] flip `time`sym`price`size`side!1000?/:(.z.p;`3;100f;100;"bs")
lbs      | 17
alg      | 2
lvl      | 0
dataCount| 1000
testTime | 0D00:00:00.424485159
queryTime| 0D00:00:00.000243493
```

The return value is a dictionary with the LBS, algorithm, level, total test time, and (average) query time values values.

### testQueryAll

Test a query on a compressed table for all compression parameter combinations.

```q
.zipPerf.testQueryAll[query;table]
```

* `query` - Query to apply. Can be a QSQL query as a string (table name does not matter as it is replaced). Otherwise, query functional form with first param (table) missing.
* `table` - Table data to test.

#### Example - Compression with all possible LBS, algorithm, and level combinations

```q
q).zipPerf.testQueryAll["select avg price by sym from t";] flip `time`sym`price`size`side!1000?/:(.z.p;`3;100f;100;"bs")
lbs alg lvl dataCount testTime             queryTime           
---------------------------------------------------------------
0   0   0   1000      0D00:00:00.401942610 0D00:00:00.000200729
12  1   0   1000      0D00:00:00.407015223 0D00:00:00.000205610
12  2   0   1000      0D00:00:00.431666294 0D00:00:00.000201856
12  2   1   1000      0D00:00:00.424191757 0D00:00:00.000347730
12  2   2   1000      0D00:00:00.430291332 0D00:00:00.000336117
12  2   3   1000      0D00:00:00.431817517 0D00:00:00.000327068
12  2   4   1000      0D00:00:00.437688681 0D00:00:00.000333754
12  2   5   1000      0D00:00:00.434028278 0D00:00:00.000331969
12  2   6   1000      0D00:00:00.432250174 0D00:00:00.000336008
12  2   7   1000      0D00:00:00.420087698 0D00:00:00.000341273
12  2   8   1000      0D00:00:00.453328214 0D00:00:00.000324735
12  2   9   1000      0D00:00:00.439938019 0D00:00:00.000340894
12  3   0   1000      0D00:00:00.413735690 0D00:00:00.000210752
..
```

The return value is a table where each row corresponds to the (average) query time value of some LBS-algorithm-level combination.

## Other Functions

### factor

Compute the compression factor.

```q
.zipPerf.factor file
```

* `file` - Path to file to compute compression factor for.

#### Example - Computing compression factor

```q
// Uncompressed file
q)`:uncompressedFile set data
q).zipPerf.factor `:uncompressedFile
0n

// Compressed file
q)(`:compressedFile;16;1;0) set data
q).zipPerf.factor `:compressedFile
3.476149
```
