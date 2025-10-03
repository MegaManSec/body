_body_: print the middle line(s) of files.


`body [-A <lines_after>] [-B <lines_before>] [-C <lines_before_and_after>] [--color=WHEN] [-n] [-N] <filename(s)>`

parameters:

-A[number]: print _number_ lines after the middle line.

-B[number]: print _number_ lines before the middle line.

-C[number]: print _number_ lines before and after the middle line.

-n: do not print the line number(s), just print the contents of the line(s).

-N: do not print the file name (only utilized if multiple files filenames are specified).

--color=WHEN: `always`, `never`, or `auto` use colors in output.

filename: file to parse. can be specified multiple times. if multiple files are specified, the file name is also printed.

by default, only the middle line is shown.

examples:

```bash
$ body /etc/passwd /etc/group
/etc/passwd:65:_dpaudio:*:215:215:DP Audio:/var/empty:/usr/bin/false
/etc/group:79:_atsserver:*:97:

$ body -A3 -B1 /etc/passwd  /etc/group
/etc/passwd:64:_dovecot:*:214:6:Dovecot Administrator:/var/empty:/usr/bin/false
/etc/passwd:65:_dpaudio:*:215:215:DP Audio:/var/empty:/usr/bin/false
/etc/passwd:66:_postgres:*:216:216:PostgreSQL Server:/var/empty:/usr/bin/false
/etc/passwd:67:_krbtgt:*:217:-2:Kerberos Ticket Granting Ticket:/var/empty:/usr/bin/false
/etc/passwd:68:_kadmin_admin:*:218:-2:Kerberos Admin Service:/var/empty:/usr/bin/false
/etc/group:78:_installer:*:96:
/etc/group:79:_atsserver:*:97:
/etc/group:80:_lpadmin:*:98:
/etc/group:81:_unknown:*:99:
/etc/group:82:_lpoperator:*:100:

$ body -C1 /etc/passwd
64:_dovecot:*:214:6:Dovecot Administrator:/var/empty:/usr/bin/false
65:_dpaudio:*:215:215:DP Audio:/var/empty:/usr/bin/false
66:_postgres:*:216:216:PostgreSQL Server:/var/empty:/usr/bin/false
```

---

benchmarks:

given the following test file:

```bash
#!/bin/bash

file="/var/log/auth.log.1"

benchmark_command() {
  local start_time=$(date +%s.%N)
  for i in {1..20}; do
   eval "$1" >/dev/null
   echo 3 > /proc/sys/vm/drop_caches
  done
  local end_time=$(date +%s.%N)
  local elapsed_time=$(echo "$end_time - $start_time" | bc -l)
  local average_time=$(echo "$elapsed_time / 10" | bc -l)
  printf "%.6f " "$average_time"
}
echo 3 > /proc/sys/vm/drop_caches

benchmark_command "lines=\$(wc -l < $file); lines=\$((lines/2)); head -n\$lines $file | tail -n1"

benchmark_command "lines=\$(wc -l < $file); lines=\$((lines/2)); cat -n $file | head -n\$lines | tail -n1"

benchmark_command "lines=\$(wc -l < $file); lines=\$((lines/2)); sed \$lines,\$lines'!d;=' $file | sed 'N;s/\\n/ /'"

benchmark_command "lines=\$(wc -l < $file); lines=\$((lines/2)); awk 'NR==$lines{print NR\" \"\$0}' $file"

benchmark_command "lines=\$(wc -l < $file); lines=\$((lines/2)); cat -n $file | sed -n \$lines,\${lines}p"

echo
```

executed 20 times, the results come out as:

```bash
 for i in {1..20}; do bash /tmp/test; done  | awk '{
    for (i = 1; i <= NF; i++) {
        sum[i] += $i
        count[i]++
    }
}
END {
    for (i = 1; i <= NF; i++) {
        printf "avg %d: %.2f\n", i, sum[i] / count[i]
    }
}'
avg 1: 0.12
avg 2: 0.14
avg 3: 0.13
avg 4: 0.17
avg 5: 0.17
```


The winner is clearly `head | tail`, but this isn't as useful since we want to print filenames and line numbers too, to sed it is!

previously, the script used:

```bash
awk 'NR>='"$start_line"' && NR<='"$end_line"' {print NR ":" $0}' "$filename" 2>/dev/null
```

now it uss:

```bash
sed "$start_line,$end_line"'!d;=' "$filename" | sed 'N;s/\n/:/' | sed "s|^|$filename:|"
```
