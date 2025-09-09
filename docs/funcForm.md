
# QSQL to Functional Form Converter

Converion of QSQL queries into their equivalent functional form.

## Usage

Invoke with the `-q` option to run in quiet mode so the Q startup banner is not printed.

```bash
$ q funcForm.q <QSQL Query> -q
```

## Examples

### Simple exec

```bash
$ q src/funcForm.q "exec a from table" -q
# => ?[table;();();`a]
```

### Simple select

```bash
$ q funcForm.q "select from table" -q
# => ?[table;();0b;()]
```

### Simple update

```bash
$ q src/funcForm.q "update a:10 from table" -q
# => ![table;();0b;(enlist`a)!10]
```

### Complex query

```bash
$ q src/funcForm.q "select count i from trade where 140>(count;i) fby sym" -q
# => ?[trade;enlist (>;140;(fby;(enlist;count;`i);`sym));0b;(enlist`x)!enlist (count;`i)]
```

### Fifth and sixth arguments

```bash
$ q src/funcForm.q "select[10 20;>price] from trade" -q
# => ?[trade;();0b;();10 20;(idesc;`price)]
```

### Nested query

```bash
$ q src/funcForm.q "select from (select from table) where qty>10" -q
# => ?[?[table;();0b;()];enlist (>;`qty;10);0b;()]
```
