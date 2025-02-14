
/
    @file
        run.q
    
    @description
        Run all unit tests.
\

.pkg.load `os`unit;

PATH_UNIT:first ` vs .os.file[];
PATH_ROOT:` sv PATH_UNIT,2#`..;
PATH_SRC:.Q.dd[PATH_ROOT;`src];

.unit.loadSuites PATH_UNIT;
results:.unit.run[];
.unit.printResults results;

exit 0;
