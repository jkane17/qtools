
# Dummy Database Builder

Create a dummy splayed or partitioned database.

## Usage

```bash
$ q buildDB.q [OPTIONS]
```

## Options

|    Option    |                                    Description                                    |        Default        |
| ------------ | --------------------------------------------------------------------------------- | --------------------- |
| `-root`      | Path where root will be created. Must be an empty directory.                      | PWD                   |
| `-domain`    | Sym file (domain) name.                                                           | sym                   |
| `-dbtype`    | The type of database (splay or part).                                             | splay                 |  
| `-ptype`     | Partion type (date, month, year, or int).                                         | date                  |
| `-nparts`    | Number of partions to create (overwritten if partstart & partend provided).       | 1                     |
| `-partstart` | First partition (e.g., 2025.01.01, 2025.01m, 1).                                  | (TODAY - nparts) or 1 |
| `-partend`   | Last partition (e.g., 2025.12.31, 2025.12m, 10).                                  | TODAY or nparts       |
| `-ntabs`     | Number of tables per partition.                                                   | 1                     |
| `-nrows`     | Number of rows per table.                                                         | 1                     |
| `-ncols`     | Number of cols per table.                                                         | 1                     |
| `-nsymcols`  | Number of sym cols per table.                                                     | 0                     |
| `-nsyms`     | Max number of distinct symbols (may be lower depending on ntabs, ncols, & nrows). | 100                   |

## Examples

Examples are invoked with the `-q` option to run in quiet mode so the Q startup banner is not printed.

### No options

Inside an empty directory we can provide no options to use all the defaults:

```bash
$ q buildDB.q -q

Creating splayed database: .
Database created
Time taken: 0.001 seconds
Disk usage of database: 35 bytes

$ ls
t1
$ ls -a t1
.  ..  .d  c1
```

### Providing a root

We can provide a name for our DB root and it will be created for us:

```bash
$ q buildDB.q -q -root testDB

Creating splayed database: testDB
Database created
Time taken: 0.003 seconds
Disk usage of database: 35 bytes

$ ls testDB
t1
$ ls -a testDB/t1
.  ..  .d  c1
```

### More tables, columns, & rows

Create a splayed DB with 5 tables. Each table will have 6 columns and 100 rows each.

```bash
$ q buildDB.q -q -root testDB -ntabs 5 -ncols 6 -nrows 100

Creating splayed database: testDB
Database created
Time taken: 0.010 seconds
Disk usage of database: 41,178 bytes

$ ls testDB
t1  t2  t3  t4  t5
$ ls -a testDB/t1
.  ..  .d  c1  c2  c3  c4  c5  c6
$ ls -a testDB/t2
.  ..  .d  c1  c2  c3  c4  c5  c6

$ q testDB
```

```q
q)tables[]
`s#`t1`t2`t3`t4`t5
// Column types and data is random
q)first t1
c1| 2000.08m
c2| 2009.05.20
c3| "F"
c4| 2021.11.26D00:55:13.656948992
c5| 47e055b4-b59d-1e45-2904-089f21ae45e1
c6| 2022.09.02T23:39:36.968
q)count t1
100
```

### Adding symbols

As symbol columns are special in a splayed/partitioned database, there are options that allow control over the number of symbol columns per table as well as the maximum number of distinct symbols in the database.

Here, each table will have 1 symbol type column and there will only be up to 50 distinct symbols in our database:

```bash
$ q buildDB.q -q -root testDB -ntabs 5 -ncols 6 -nrows 100 -nsymcols 1 -nsyms 50

Creating splayed database: testDB
Database created
Time taken: 0.007 seconds
Disk usage of database: 40,068 bytes

# A sym file is now present
$ ls testDB
sym  t1  t2  t3  t4  t5

$ q testDB
```

```q
// c1 is enumerated against our sym file
q)first t1
c1| `sym$`gkpmjcag
c2| 26h
c3| 45.7e
c4| 2019.08.10T17:07:30.025
c5| 59i
c6| 08391622-0035-fae0-aa9f-c4f9ae6f4c30

q)sym
`gkpmjcag`jognjhck`ejcjbcdh..
q)count sym
50
```

`-nsyms` only limits the number of distinct symbols, but the actual size of the sym file might be smaller depending on the number of actual symbol values need. For example, if you set `-nsyms` to 50, but only have 1 table with 10 rows and 1 symbol column, then there could only ever be 10 distinct symbol values.

### Partitioning

Create a date partitioned DB with 5 partitions:

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5

Creating partioned database: testDB
Database created
Time taken: 0.004 seconds
Disk usage of database: 175 bytes

# Last partition is today's date by default
$ ls testDB
2025.09.05  2025.09.06  2025.09.07  2025.09.08  2025.09.09
$ ls testDB/2025.09.05
t1
```

### Partition range

We can control the start and end partitions using `-partstart` and `-partend`.

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5 -partend 2025.01.17
..

$ ls testDB
2025.01.13  2025.01.14  2025.01.15  2025.01.16  2025.01.17
```

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5 -partstart 2025.01.17
..

$ ls testDB
2025.01.17  2025.01.18  2025.01.19  2025.01.20  2025.01.21
```

```bash
$ q buildDB.q -q -root testDB -dbtype part -partstart 2025.01.01 -partend 2025.01.17
..

$ $ ls testDB
2025.01.01  2025.01.03  2025.01.05  2025.01.07  2025.01.09  2025.01.11  2025.01.13  2025.01.15  2025.01.17
2025.01.02  2025.01.04  2025.01.06  2025.01.08  2025.01.10  2025.01.12  2025.01.14  2025.01.16
```

### Partition types

4 partition types are supported: date (default), month, year, and int.

We can select which to use via the `-ptype` option.

#### date

```bash
# Default is date
$ q buildDB.q -q -root testDB -dbtype part -nparts 5

$ ls testDB
2025.09.05  2025.09.06  2025.09.07  2025.09.08  2025.09.09

$ q testDB
```

```q
q)select from t1 where date=.z.d
date       c1
----------------------------------
2025.09.09 2020.03.02T06:57:38.633
```

#### month

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5 -ptype month

$ ls testDB
2025.05  2025.06  2025.07  2025.08  2025.09

$ q testDB
```

```q
q)select from t1 where month="m"$.z.d
month   c1
-------------------------------
2025.09 2020.03.02T06:59:33.884
```

#### year

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5 -ptype year

$ ls testDB
2021  2022  2023  2024  2025

$ q testDB
```

```q
q)select from t1 where year=`year$.z.d
year c1
----------------------------
2025 2020.03.02T07:01:10.012
```

#### int

```bash
$ q buildDB.q -q -root testDB -dbtype part -nparts 5 -ptype int

$ ls testDB
1  2  3  4  5

$ q testDB
```

```q
q)select from t1 where int=1
int c1
---------------------------
1   2013.04.03T15:40:00.740
```
