#! /bin/sh

# Script to create the postgres user $1
# This script runs as the user USER

# There is no error checking!!
if [ $# -eq 0 ]
  then
      echo "No user name supplied !!"
      exit 1
      fi
DBROLE=$1
echo "Check if role exists:"
# check if this role already exists in the database
ROLE_EXISTS=`sudo - postgres bash -c "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${DBROLE}';\""`
IS_ROLE="0"${ROLE_EXISTS}"0"
if [ $IS_ROLE = 010 ]
then
echo "User ${DBROLE} already exists in the database!!!!"
exit 1
fi
echo "Role does not exist, create it......"
DBPASSWD="user"`shuf -i 0-9999 -n 1`
echo "The password for user ${DBROLE} is: ${DBPASSWD}"
date  >> /local0/dbmaint/GeneiousPasswords.lst
echo "The password for user ${DBROLE} is: ${DBPASSWD}" >> /local0/dbmaint/GeneiousPasswords.lst
echo "-------------------------------------------------------" >> /local0/dbmaint/GeneiousPasswords.lst


# create role
sudo -u postgres bash -c "psql -c \"CREATE ROLE ${DBROLE} WITH LOGIN PASSWORD '${DBPASSWD}';\"" 2>>/local0/dbmaint/CreateDBUser_error.txt
# grant role privileges on geneious database
sudo -u postgres bash -c "psql geneious -c \"GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO ${DBROLE};\"" 2>>/local0/dbmaint/CreateDBUser_error.txt

## end


