#!/bin/env python3
#
import sys, os, subprocess, grp, time, argparse
sys.path.insert(0, '/root/bin/pythonModules')
import dbconnect, logCollector

#
# Define a System command
#
def execute(cmd):
  """ Call subprocess.getstatusoutput instead of the older os.popen method.
  This returns a tuple with the status value and the output of the command """
  return subprocess.getstatusoutput(cmd)

def checklock():
  try:
    with open('/var/run/snapshots/.manager.py.lck') as lockfile:
      reported_pid = lockfile.read().strip()
      if len(reported_pid) == 0:
                removelock()
      cmd = 'ps -ef |grep ' +reported_pid+ ' |grep -v grep|wc -l'
      if int((execute(cmd))[1].strip()) == int(0):
        print("Removed lockfile for PID " +reported_pid)
        removelock()
        checklock()
      else:
        sys.exit("Lock file already exists")
  except IOError as err:
    if not os.path.exists('/var/run/snapshots'):
      os.makedirs('/var/run/snapshots')
    try:
      with open('/var/run/snapshots/.manager.py.lck', 'w') as lockfile:
        lockfile.write(str(os.getpid()))
      with open('/var/run/snapshots/.manager.py.lck') as lockfile:
        return()
    except IOError as err:
      print("Unable to create lockfile")
      
def removelock():
  os.remove('/var/run/snapshots/.manager.py.lck')

def doSnapshot(parameters):
  """ This function does a few checks, then calls /root/bin/snapshotZfs.sh with the required parameters """
  id, filesystem, reqd_alias, children, retention, destination, dest_fs, create_new, active, lastrun, interval = parameters
# Firstly, and importantly, check that "Required host" is true"
  cmd = 'host ' +reqd_alias+ '|grep address|nawk \'{print $4}\''
  reqd_ip = execute(cmd)[1].strip().split("\n")[0]
  cmd = 'ifconfig -a|grep ' +reqd_ip
  if len(execute(cmd)[1].strip().split("\n")[0]) != 0:
    pass
  else:
    logCollector.setLogState(2, 'Host alias ' +reqd_alias+ ' incorrect')
    removelock()
    sys.exit('Host alias ' +reqd_alias+ ' incorrect')
# Check if we should create the snapshot(y), or it already exists(n)
  if create_new == True:
    create = "y"
  else:
    create = "n"
# Firstly make sure it hasn't been disabled
  if active == True:
# If all checks are okay, go ahead and do the snapshot
    now = time.time()
    thisrun = time.strftime('%Y-%m-%d %H:%M')
    if lastrun == None:
      (lastrun, interval) = (0, 0)
# Check interval time, allowing a 30 minute grace, because we only run every hour
    if now >= lastrun + interval - 1800:
      script = '/root/bin/snapshotZfs.sh'
      identifier = hostname[-6:]+ 'to' +destination[-6:]
      cmd = script+ ' -h ' +destination+ ' -l ' +filesystem+ ' -r ' +dest_fs+ '/ -f ' +children+ ' -k' +str(retention)+ ' -c' +create+ ' -i' +identifier
      exitstatus, output = execute(cmd)
# Write to a logfile
      try:
        with open('/var/log/snapshotManager.log', 'a') as log_file:
          print(time.strftime('%Y-%m-%d %H:%M:%S'), '\n', output, sep='', file=log_file)
      except IOError as err:
        print('File error: ' + str(err))

      if exitstatus == 0:
        values = (thisrun, id)
        insert_sql = "UPDATE snapshot set lastrun = %s WHERE id = '%s'" 
        try:
          dbconnect.dbexecute(conn, insert_sql, values)
          conn.commit()
        except:
          logCollector.setLogState(2, 'Database connection error')
#
# Main logic section
#
if __name__ == '__main__':
  """Firstly establish parameters then setup empty values  and dictionaries"""
  parser = argparse.ArgumentParser(
    description='A programme that manages ZFS snapshots, using a PostgreSQL database as a configuration source',
    epilog="Eg: " +os.path.split(sys.argv[0])[1])
  parser.add_argument('-v', '--verbose', default=False, help='verbosity level - 1, 2 or 3')
  parser.add_argument('-d', '--dryrun', default=False, help='Dry Run.  "-dry" will not perform a snapshot')
  args = parser.parse_args()
  verbose = vars(args)['verbose']
  dryrun = vars(args)['dryrun']

  today = time.strftime('%Y-%m-%d')
  hostname = os.uname()[1]
  conn = dbconnect.createConnection('zfs_snapshots')

# Check we can connect to database first, if not report error 
  try:
    query_string = "SELECT count(*) from destination"
    dbconnect.dbquery(conn, query_string)
  except:
    logCollector.setLogState(2, 'database onnect test failed')
    removelock()

# Okay to start
  checklock()

# Establish what ZFS Pools exist, and check what filesystems are to be snapshotted.
  cmd = 'zpool list -H|grep dataPool'
  for line in execute(cmd)[1].strip().split("\n"):
    pool_line = line.split("\t")
    pool = pool_line[0]
# For each Pool found, find each filesystem, but only to a depth of 2
    cmd = 'zfs list -H -d2 -r ' +pool
    for line in execute(cmd)[1].strip().split("\n"):
      fs_line = line.split("\t")
      fs = fs_line[0]
# Query zfs_snapshots database
      query_string = "SELECT t.id, s.filesystem, s.reqd_alias, s.children, s.retention, \
        d.host, d.filesystem, t.create_new, t.active, extract(epoch FROM t.lastrun), t.interval \
        FROM source s, destination d, snapshot t \
        WHERE s.id = t.source_id \
        AND d.id = t.destination_id \
        AND s.filesystem = '%s' \
        AND s.host = '%s' ; " % (fs, hostname)
      exists = dbconnect.dbquery(conn, query_string)
# This produces a list of tuples like:
# ('3', 'dataPool/snapshots/home', 'bs-home', '/export/group', '100', 'bs-ssvr01', 'dataPool/snapshots/home', False, True, '1299668400', '14400')
      if exists == None:
        pass
      else:
        for params in exists[:]:
          doSnapshot(params)
  removelock()
