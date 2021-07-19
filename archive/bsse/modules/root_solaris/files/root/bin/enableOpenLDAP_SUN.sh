#!/usr/bin/bash

echo "1.) Preparing ldap certificate."

if [ ! -x `which certutil|awk '{print $1}'` ]; then
	echo "1a.) Installing certutil This can take minutes!"
	pkg install nss-utilities
fi

cat >/root/qvroot2.crt <<EOF
-----BEGIN CERTIFICATE-----
MIIFtzCCA5+gAwIBAgICBQkwDQYJKoZIhvcNAQEFBQAwRTELMAkGA1UEBhMCQk0x
GTAXBgNVBAoTEFF1b1ZhZGlzIExpbWl0ZWQxGzAZBgNVBAMTElF1b1ZhZGlzIFJv
b3QgQ0EgMjAeFw0wNjExMjQxODI3MDBaFw0zMTExMjQxODIzMzNaMEUxCzAJBgNV
BAYTAkJNMRkwFwYDVQQKExBRdW9WYWRpcyBMaW1pdGVkMRswGQYDVQQDExJRdW9W
YWRpcyBSb290IENBIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCa
GMpLlA0ALa8DKYrwD4HIrkwZhR0In6spRIXzL4GtMh6QRr+jhiYaHv5+HBg6XJxg
Fyo6dIMzMH1hVBHL7avg5tKifvVrbxi3Cgst/ek+7wrGsxDp3MJGF/hd/aTa/55J
WpzmM+Yklvc/ulsrHHo1wtZn/qtmUIttKGAr79dgw8eTvI02kfN/+NsRE8Scd3bB
rrcCaoF6qUWD4gXmuVbBlDePSHFjIuwXZQeVikvfj8ZaCuWw419eaxGrDPmF60Tp
+ARz8un+XJiM9XOva7R+zdRcAitMOeGylZUtQofX1bOQQ7dsE/He3fbE+Ik/0XX1
ksOR1YqI0JDs3G3eicJlcZaLDQP9nL9bFqyS2+r+eXyt66/3FsvbzSUr5R/7mp/i
Ucw6UwxI5g69ybR2BlLmEROFcmMDBOAENisgGQLodKcftslWZvB1JdxnwQ5hYIiz
PtGo/KPaHbDRsSNU30R2be1B2MGyIrZTHN81Hdyhdyox5C315eXbyOD/5YDXC2Og
/zOhD7osFRXql7PSorW+8oyWHhqPHWykYTe5hnMz15eWniN9gqRMgeKh0bpnX5UH
oycR7hYQe7xFSkyyBNKr79X9DFHOUGoIMfmR2gyPZFwDwzqLID9ujWc9Otb+fVuI
yV77zGHcizN300QyNQliBJIWENieJ0f7OyHj+OsdWwIDAQABo4GwMIGtMA8GA1Ud
EwEB/wQFMAMBAf8wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBQahGK8SEwzJQTU7tD2
A8QZRtGUazBuBgNVHSMEZzBlgBQahGK8SEwzJQTU7tD2A8QZRtGUa6FJpEcwRTEL
MAkGA1UEBhMCQk0xGTAXBgNVBAoTEFF1b1ZhZGlzIExpbWl0ZWQxGzAZBgNVBAMT
ElF1b1ZhZGlzIFJvb3QgQ0EgMoICBQkwDQYJKoZIhvcNAQEFBQADggIBAD4KFk2f
BluornFdLwUvZ+YTRYPENvbzwCYMDbVHZF34tHLJRqUDGCdViXh9duqWNIAXINzn
g/iN/Ae42l9NLmeyhP3ZRPx3UIHmfLTJDQtyU/h2BwdBR5YM++CCJpNVjP4iH2Bl
fF/nJrP3MpCYUNQ3cVX2kiF495V5+vgtJodmVjB3pjd4M1IQWK4/YY7yarHvGH5K
WWPKjaJW1acvvFYfzznB4vsKqBUsfU16Y8Zsl0Q80m/DShcK+JDSV6IZUaUtl0Ha
B0+pUNqQjZRG4T7wlP0QADj1O+hA4bRuVhogzG9Yje0uRY/W6ZM/57Es3zrWIozc
hLsib9D45MY56QSIPMO661V6bYCZJPVsAfv4l7CUW+v90m/xd2gNNWQjrLhVoQPR
TUIZ3Ph1WVaj+ahJefivDrkRoHy3au000LYmYjgahwz46P0u05B/B5EqHdZ+XIWD
mbA4CD/pXvk1B+TJYm5Xf6dQlfe6yJvmjqIBxdZmv3lh8zwc4bmCXF2gw+nYSL0Z
ohEUGW6yhhtoPkg3Goi3XZZenMfvJ2II4pEZXNLxId26F0KCl3GBUzGpn/Z9Yr9y
4aOTHcyKJloJONDO1w2AFrR4pTqHTI2KpdVGl/IsELm8VCLAAVBpQ570su9t+Oza
8eOx79+Rj1QqCyXBJhnEUhAFZdWCEOrCMc0u
-----END CERTIFICATE-----
EOF
cat >/root/qvsslg2.crt <<EOF
-----BEGIN CERTIFICATE-----
MIIFTDCCAzSgAwIBAgIUSJgt4qkssznhyPkzNYJ10+T4glUwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQk0xGTAXBgNVBAoTEFF1b1ZhZGlzIExpbWl0ZWQxGzAZ
BgNVBAMTElF1b1ZhZGlzIFJvb3QgQ0EgMjAeFw0xMzA2MDExMzM1MDVaFw0yMzA2
MDExMzM1MDVaME0xCzAJBgNVBAYTAkJNMRkwFwYDVQQKExBRdW9WYWRpcyBMaW1p
dGVkMSMwIQYDVQQDExpRdW9WYWRpcyBHbG9iYWwgU1NMIElDQSBHMjCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBAOHhhWmUwI9X+jT+wbho5JmQqYh6zle3
0OS1VMIYfdDDGeipY4D3t9zSGaNasGDZdrQdMlY18WyjnEKhi4ojNZdBewVphCiO
zh5Ni2Ak8bSI/sBQ9sKPrpd0+UCqbvaGs6Tpx190ZRT0Pdy+TqOYZF/jBmzBj7Yf
XJmWxlfCy62UiQ6tvv+4C6W2OPu1R4HUD8oJ8Qo7Eg0cD+GFsBM2w8soffyl+Dc6
pKtARmOClUC7EqyWP0V9953lA34kuJZlYxxdgghBTn9rWoaQw/Lr5Fn0Xgd7fYS3
/zGhmXYvVsuAxIn8Gk+YaeoLZ8H9tUvnDD3lEHzvIsMPxqtd7IgcVaMCAwEAAaOC
ASowggEmMBIGA1UdEwEB/wQIMAYBAf8CAQAwEQYDVR0gBAowCDAGBgRVHSAAMHIG
CCsGAQUFBwEBBGYwZDAqBggrBgEFBQcwAYYeaHR0cDovL29jc3AucXVvdmFkaXNn
bG9iYWwuY29tMDYGCCsGAQUFBzAChipodHRwOi8vdHJ1c3QucXVvdmFkaXNnbG9i
YWwuY29tL3F2cmNhMi5jcnQwDgYDVR0PAQH/BAQDAgEGMB8GA1UdIwQYMBaAFBqE
YrxITDMlBNTu0PYDxBlG0ZRrMDkGA1UdHwQyMDAwLqAsoCqGKGh0dHA6Ly9jcmwu
cXVvdmFkaXNnbG9iYWwuY29tL3F2cmNhMi5jcmwwHQYDVR0OBBYEFJEZYq1bF6cw
+/DeOSWxvYy5uFEnMA0GCSqGSIb3DQEBCwUAA4ICAQB8CmCCAEG1Lcw55fTba84A
ipwMieZydFO5bcIh5UyXWgWZ6OP4jb/6LaifEMLjRCC0mU14G6PrPU+iZQiIae7X
5EavhmETEA8JbLICjiD4c9Y6+bgMt4szEPiZ2SALOQj10Br4HKQfy/OvbedRbLax
p9qlDG4qJgSt3uikDIJSarx6mpgEQXu00UZNkiEYUfeO8hXGXrZbtDnkuaiVDtM6
s9yYpcoyFxFOrORrEgViaI7P3EJaDYmI6IDUIPaSBM6GrVMiaINYEMBL1v2jZi8r
XDY0yVsZ/0DAIQiCBNNvT1NjQ5Sn1E+O+ZBiqDD+rBvBoPsI6ydfdKtJur5YL+Oo
kJK2eLrce8287awIcd8FMRDcZw/NX1bc8uKye5OCtwpQ0d4jL4emuXwFv8TqUbZh
2xJShyy57cqw3qWoBOs/WWza29/Hun8PXkQoZepwY/xc+9nI1NaKM8NqhSqJNTJl
vXj7zb3mdpbe3YR9BkSXProlN7l5KOx54gJ7kJ7r6qJYJux03HyPM11Kp4wfdn1R
sC2UQ5awC6fg/3XE2HZVkyqJjKwqh4nFaiK5EMV7DHQ4oJx9ckmDw6pBvDaoPokX
yzdfJ72n+1JfHGP+workciKNldgqYX6J4jPrCIEIBrtDta4QxP10Tyd9RFu13XmE
8SYi/VXvrf3nriQfAZ/nSA==
-----END CERTIFICATE-----
EOF

cat >/etc/nsswitch.ldap <<EOF
#
# /etc/nsswitch.ldap: D-BSSE Solaris 11
#
passwd:     files ldap
group:      files ldap
automount:  files ldap
hosts:      files dns
ipnodes:    files
networks:   files
protocols:  files
rpc:        files
ethers:     files
netmasks:   files
bootparams: files
publickey:  files
netgroup:   ldap
aliases:    files
services:   files
printers:   user files
auth_attr:  files
prof_attr:  files
project:    files
tnrhtp:     files
tnrhdb:     files
EOF

cd /var/ldap
echo "1b.) Please hit RETURN twice (dont use password for the cert keystore)"
certutil -N -d .
certutil -A -n QVroot2 -i /root/qvroot2.crt -t c -d .
certutil -A -n QVsslg2 -i /root/qvsslg2.crt -t CT -d .

echo "2.) Creating LDAP conf. This might take up to some minutes"

ldapclient manual -a credentialLevel=proxy \
-a authenticationMethod=tls:simple \
-a proxyDN=cn=ldap_proxy,ou=admins,ou=bsse,ou=auth,o=ethz,c=ch \
-a "proxyPassword=oleex.e+k3ahqu-eG1oh" \
-a followReferrals=false \
-a "defaultSearchBase=ou=auth,o=ethz,c=ch" \
-a domainName=ethz.ch \
-a defaultSearchScope=sub \
-a "defaultServerList=ldaps-rz-1.ethz.ch ldaps-rz-2.ethz.ch ldaps-hit-1.ethz.ch ldaps-hit-2.ethz.ch" \
-a attributeMap=passwd:gidnumber=bsseGidNumber \
-a attributeMap=passwd:homedirectory=bsseHomeDirectory \
-a attributeMap=passwd:loginshell=bsseLoginShell \
-a "serviceSearchDescriptor=passwd:ou=users,ou=nethz,ou=id,ou=auth,o=ethz,c=ch?sub?objectClass=bssePosixAccount" \
-a "serviceSearchDescriptor=shadow:ou=users,ou=nethz,ou=id,ou=auth,o=ethz,c=ch?sub?objectClass=bssePosixAccount" \
-a "serviceSearchDescriptor=netgroup:ou=netgroup,ou=bsse,ou=auth,o=ethz,c=ch?sub" \
-a "serviceSearchDescriptor=automount:ou=automount,ou=bsse,ou=auth,o=ethz,c=ch?sub" \
-a serviceSearchDescriptor=group:ou=maillist,ou=groups,ou=nethz,ou=id,ou=auth,o=ethz,c=ch

svcadm restart name-service/switch
svcadm restart svc:/system/name-service-cache:default
svcadm restart svc:/network/dns/client:default

echo "3.) Preparing automount"
test -f /etc/auto_master && rm /etc/auto_master
test -f /etc/auto_home && rm /etc/auto_home
svcadm disable autofs
svcadm enable autofs
svcadm disable mapid
svcadm enable mapid
svcadm disable idmap
svcadm enable idmap
svcadm refresh svc:/milestone/name-services:default
svcadm refresh svc:/system/name-service-cache:default

echo Waiting for the system...
sleep 2

id -a ryanj

# ldapsearch -b OU=servers,OU=BSSE-Department,OU=BSSE,OU=Hosting,DC=d,DC=ethz,DC=ch -D cn=bs-adbind,ou=EthUsers,dc=d,dc=ethz,dc=ch -h  82.130.70.7 -x -W cn=bs-dsvr*
