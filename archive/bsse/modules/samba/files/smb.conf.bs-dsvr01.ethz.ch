[global]

   workgroup = D
   log level = 0

   server string = ITSC server 1
   netbios aliases = bs-dsvr01

   security = ads
   hosts allow = 129.132.228.0/23 129.132.42.0/24 129.132.27.0/24 172.31.52.129/25 129.132.49.160/28 127. 195.176.122.0/24
   load printers = yes
   cups options = raw
   log file = /var/log/samba/%m.log
   max log size = 50

   password server = novo.d.ethz.ch crack.d.ethz.ch lido.d.ethz.ch epo.d.ethz.ch
   realm = D.ETHZ.CH
   use kerberos keytab = true
   dns proxy = no 

[homes]
   comment = Home Directories
   browseable = no
   writable = yes

[net]
   comment = net automount
   path = /net
   browseable = yes
   writable = yes
   valid users = @su-user @it-user root

[backup]
   comment = Image dumping on bs-ssvr02
   ; path=/array0/backup
   path=/net/bs-ssvr02/array0/itsc/backup/
   browseable = yes
   writeable = yes
   public = no
   guest ok = no
   valid users = @su-user @it-user root

[tmp]
   comment = Temporary file space
   path = /array0/tmp
   read only = no
   public = yes
   valid users = @su-user @it-user root localuser

[local0]
   comment = Local data area
   path = /local0
   read only = no
   public = no
   valid users = @su-user @it-user root localuser

[dsfdata]
   comment = DSU share from ssvr01
   path =  /net/bs-ssvr01/array0/bsse/bsse-dsf
   read only = yes
   public = no
   writeable = no
   valid users = @it-user,@su-user,@dsf-user

[printers]
   comment = All Printers
   path = /usr/spool/samba
   browseable = no
   guest ok = no
   writable = no
   printable = yes

