
# Database Maintenance Utilities

This script is a modernised version of the original KX dbmaint.q script used for database maintenance.

## Loading

The script can be loaded into a Q session on startup:

```bash
$q dbm.q
```

or it can be loaded into a running Q session:

```q
q)\l dbm.q
```

## Functions

### addCol

Add a column to a splayed table, in all partitions if the database is partitioned.

```q
.dbm.addCol[db;domain;tname;cname;default]
```

* `db` - Path to database root.
* `domain` - Sym file (domain) name (only required if column is symbol type).
* `tname` - Table name.
* `cname` - Column name.
* `default` - Default value of the column.

#### Examples

Add a new column (`newCol`) to the `trade` table with a default value of 10:

```q
.dbm.addCol[`:/my/db;`;`trade;`newCol;10]
```

Add a new column (`newSymCol`) to the `trade` table, within all partitions under `db`, with a default value of `` `abc``, enumeated against `mySym`:

```q
.dbm.addCol[`:/my/db;`mySym;`trade;`newSymCol;`abc]
```








     

### .dbm.fnCol

Multiply the *price* column in the *trade* table by 2.
```q
.dbm.fnCol[`:/my/db;`trade;`price;2*]
```

Make the characters in the *alpha* column of the *trade* table uppercase.
```q
.dbm.fnCol[`:/my/db;`trade;`alpha;upper]
```

<br />        

### .dbm.castCol

Cast the *time* column in the *trade* table to *second* type.
```q
.dbm.castCol[`:/my/db;`trade;`time;`second]
```

<br />        

### .dbm.setAttr

Apply the parted attribute to the *sym* column in the *trade* table
```q
.dbm.setAttr[`:/my/db;`trade;`sym;`p]
```

<br />        

### .dbm.rmAttr

Remove attribute from the *sym* column in the *trade* table.
```q
.dbm.rmAttr[`:/my/db;`trade;`sym]
```

<br />        

### .dbm.copyCol

Create a copy of the *size* column in the *trade* table called *size2*.
```q
.dbm.copyCol[`:/my/db;`trade;`size;`size2]
```

<br />        

### .dbm.delCol

Delete the column *iz* from the *trade* table.
```q
.dbm.delCol[`:/my/db;`trade;`iz]
```

<br />        

### .dbm.hasCol

Does the *trade* table have the *iz* column?
```q
.dbm.hasCol[`:/my/db;`trade;`iz]      
```

<br />  

### .dbm.renameCol

Rename the *price* column of the *trade* table to *PRICE*.
```q
.dbm.renameCol[`:/my/db;`trade;`price;`PRICE]
```        
        
<br />        

### .dbm.listCols

List the columns of the *trade* table.       
```q
.dbm.listCols[`:/my/db;`trade]    
```       
        
<br />        

### .dbm.reorderCols
    
Reorder the columns of the *trade* table to be in reverse order.
```q
.dbm.reorderCols[`:/my/db;`trade;reverse cols trade]      
```

<br />        

### .dbm.addMissingCols

Add any columns, to the *trade* table, which exist in the *2023.12.19* partition, but are missing from other partition(s).
```q
.dbm.addMissingCols[`:/my/db;`trade;`:/my/db/2023.12.29/trade]     
```

<br />        

### .dbm.addTab

Add the *trade* table to the database.        
```q
.dbm.addTab[`:/my/db;`trade;([] sym:`a`b`c; price:1 2 3)]     
```

<br />        

### .dbm.renameTab

Rename the *trade* table to *transactions*.        
```q
.dbm.renameTab[`:/my/db;`trade;`transactions]     
```

<br />   

### .dbm.removeTab

Remove the *trade* table.        
```q
.dbm.removeTab[`:/my/db;`trade]     
```

