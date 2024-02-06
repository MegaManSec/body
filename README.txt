body: print the middle line(s) of files.

parameters:

-B[number]: print _number_ lines before the middle line.

-A[number]: print _number_ lines after the middle line.

-C[number]: print _number_ lines before and after the middle line.

filename: file to parse. can be specified multiple times.

examples:

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
