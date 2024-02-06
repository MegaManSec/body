body: print the middle line(s) of files.

parameters:

-B[number]: print _number_ lines before the middle line.

-A[number]: print _number_ lines after the middle line.

-C[number]: print _number_ lines before and after the middle line.

filename: file to parse. can be specified multiple times.

example: `body -A3 -B9 file.txt file2.txt`
