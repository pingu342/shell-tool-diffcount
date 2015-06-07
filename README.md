# diffcount

## Summary

Compare the two directories to count the number of changed lines.

File that have following extensions to be counted.

* m
* c
* h
* java
* cc
* cpp

## Example

* Show the differences between test/ and test_/.

    Note that test/ is a original directory and test_/ is a modified directory.

```
$ ./diffcount.pl test test_
```

* Ignore comments and blank lines.

```
$ ./diffcount.pl test test_ -i
```

* Show excluded files.

```
$ ./diffcount.pl test test_ -s
```

* Result
```
$ ./diffcount.pl test test_ -s
Processing...
 [add] added/ 0 0 0 (excluded)
 [add] added/test.c 38 0 0
 [add] added.c 38 0 0
 [del] deleted/ 0 0 0 (excluded)
 [del] deleted/test.c 0 37 0
 [del] deleted.c 0 37 0
 [mod] test/test.c 1 0 1
 [del] test-/ 0 0 0 (excluded)
 [mod] test.c 1 0 1
 [mod] test.java 0 0 1

Total file count:
 [add] 2 files (exclude 1 files)
 [del] 2 files (exclude 2 files)
 [mod] 3 files (exclude 0 files)

Total line count:
 [add] 78 lines
 [del] 74 lines
 [mod] 3 lines
```
