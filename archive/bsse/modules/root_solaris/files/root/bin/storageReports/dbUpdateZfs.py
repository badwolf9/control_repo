#!/bin/env python3

import os, time, sys, grp, psycopg2
sys.path.insert(0, '/root/bin/pythonModules')
import dbconnect, logCollector

#
# Define a System command
#
def execute(cmd):
  return os.popen(cmd).read()

#
# Strip empty fields - like spaces
#
def rm_empty(list):
  result = []
  for el in list:
    if len(el) > 0:
      result.append(el)
  return result

if __name__ == '__main__':

  today = time.strftime('%Y-%m-%d')
  conn = dbconnect.createConnection('storage_usage')
  path = (sys.argv[1])
  for fs in [path]:
    cmd = 'zfs get -Hp -d1 refer ' + fs
    for line in execute(cmd).strip().split("\n"):
      filesys, xxx, used, yyy = line.split("\t")
      mountpoint = execute("zfs get -Hp -d0 mountpoint '"+filesys+"'").strip().split("\t")[2]
      if mountpoint != "legacy":
          lsResult = execute('ls -ldn '+mountpoint)
          group = rm_empty(lsResult.split(" "))[-6]
          grname = 'unknown'
          try:
            grname = grp.getgrgid(group)[0]
          except KeyError:
            grname = 'unknown'
          except ValueError:
            grname = 'unknown'
#
#   Find out if group exists, if not create record
#
          query_string = "SELECT id FROM groups WHERE groupname = '%s'; " % (grname)
          gid = dbconnect.dbquery(conn, query_string, group)
          if gid == None:
            lsResult = execute('ls -ldn '+mountpoint)
            gid = rm_empty(lsResult.split(" "))[-6]
            values = (gid, group)
            insert_sql = "INSERT into groups (id, groupname) VALUES (%s, %s)"
            dbconnect.dbexecute(conn, insert_sql, values)
            conn.commit()
            gid = dbconnect.dbquery(conn, query_string, group)
#
#   Find out if mountpoint exists, if not create record
#
          hostname = os.uname()[1]
          query_string = "SELECT id FROM mountpoints WHERE mountpoint = '%s' AND hostname = '%s';" %(mountpoint.strip(), hostname)
          mpt_id = dbconnect.dbquery(conn, query_string)
          if mpt_id == None:
            cmd = "zfs list -H %s" % (mountpoint)
            filesys = execute(cmd).split()[0]
            print(filesys, gid[0], mountpoint.strip(), hostname);                         
            values = (filesys, gid[0], mountpoint.strip(), hostname)
            insert_sql = "INSERT into mountpoints (filesystem, group_id, mountpoint, hostname) VALUES (%s, %s, %s, %s)"
            dbconnect.dbexecute(conn, insert_sql, values)
            conn.commit()
#
#   Find out if today's record exists, if not create record
#
          mountpt_id = (dbconnect.dbquery(conn, query_string)[0])[0]
          query_string = "SELECT id FROM filesystem_size WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
          exists = dbconnect.dbquery(conn, query_string)
          if exists == None:
            values = (mountpt_id, today, used)
            insert_sql = "INSERT into filesystem_size (mountpoint_id, date, bytes) VALUES (%s, %s, %s)"
            dbconnect.dbexecute(conn, insert_sql, values)
            conn.commit()
