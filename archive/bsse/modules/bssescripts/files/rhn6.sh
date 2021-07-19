# Diese Dienste muessen fuer rhnreg_ks laufen, wenn rhn-setup aelter als 0.4.20-33.el5_5.1
if [[ $(rpm -qa rhn-setup --queryformat '%{VERSION}-%{RELEASE}') < "0.4.20-33.el5_5.1" ]]; then
  
  service messagebus status
  if [ $? -ne 0 ]; then
    service messagebus start
  fi

  service haldaemon status
  if [ $? -ne 0 ]; then
    service haldaemon start
  fi
  
fi

# evtl. Deinstallation alter SSL Zertifikate
rpm -e rhn0-ethz-trusted-ssl-cert > /dev/null 2>&1
rpm -e rhn-register-ethz > /dev/null 2>&1

# Installation der neuen Zertifikate
rpm -Uhv http://id-rhns-prd.ethz.ch/pub/rhn-org-trusted-ssl-cert-1.0-2.noarch.rpm

# Loeschen der alten osad Authentifizierungsinformationen (fuer re-registrierung notwendig)
rm -f /etc/sysconfig/rhn/osad-auth.conf > /dev/null 2>&1

# Migration von alter zu neuer Infrastruktur: alte Proxies/alter Satellite -> neuer Satellite
perl -npe 's/rhn0.ethz.ch/id-rhns-prd.ethz.ch/g' -i /etc/sysconfig/rhn/up2date
perl -npe 's/rhn1.ethz.ch/id-rhns-prd.ethz.ch/g' -i /etc/sysconfig/rhn/up2date
perl -npe 's/redhat.ethz.ch/id-rhns-prd.ethz.ch/g' -i /etc/sysconfig/rhn/up2date

# Neuinstallation: RHN Hosted Zertifikat -> RHN Satellite Zertifikat und RHN Hosted -> neuer Satellite
perl -npe 's/RHNS-CA-CERT/RHN-ORG-TRUSTED-SSL-CERT/g' -i /etc/sysconfig/rhn/up2date
perl -npe 's/xmlrpc.rhn.redhat.com/id-rhns-prd.ethz.ch/g' -i /etc/sysconfig/rhn/up2date

# Importierung der RHEL GPG-Keys
rpm --import /usr/share/rhn/RPM-GPG-KEY > /dev/null 2>&1
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release > /dev/null 2>&1

# Aktivierung/Registrierung am RHN Satellite
rhnreg_ks --force --activationkey=163-aa68b037f0a9a1719dfda9543ca91bb8
