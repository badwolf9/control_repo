#!/bin/env python3
#
import sys, os, grp, pwd, time, argparse
sys.path.insert(0, '/root/bin/pythonModules')
import dbconnect, logCollector

def cumulate(dictname, key, value):
  """Creates a set of dictionary key: value pairs, or add to an existing value"""
  try:
    dictname[key]
    dictname[key] = dictname[key] + value
  except:
    dictname[key] = value
  return(dictname)

def cumulate1(dictname, key, value1, value2):
  """Creates a set of dictionary key: value pairs, the value being a list of 2 values"""
  try:
    dictname[key]
    dictname[key] = [dictname[key][0], dictname[key][1] + value2]
  except:
    dictname[key] = [value1, value2]
  return(dictname)

def cumulate2(dictname, key, value1, value2):
  """Creates a set of dictionary key: value pairs, the value being a list of 2 values"""
  try:
    dictname[key]
    dictname[key] = [dictname[key][0] + value1, dictname[key][1] + value2]
  except:
    dictname[key] = [value1, value2]
  return(dictname)

def cumulate3(dictname, key, value1, value2, value3):
  """Creates a set of dictionary key: value pairs, the value being a list of 3 values"""
  try:
    dictname[key]
    dictname[key] = [dictname[key][0], dictname[key][1] + value2, dictname[key][2] + value3]
  except:
    dictname[key] = [value1, value2, value3]
  return(dictname)

if __name__ == '__main__':
  """Firstly establish path and hostname parameters
     then setup empty values  and dictionaries"""
  parser = argparse.ArgumentParser(
    description='A programme that injects storage statistics into a PostgreSQL database',
    epilog="Eg: " +os.path.split(sys.argv[0])[1]+ " /foo/bar nas-bsse")
  parser.add_argument('path', nargs='+', help='File system mountpoint')
  parser.add_argument('-host', '--hostname', default=[os.uname()[1]], help='host name without .ethz.ch')
  parser.add_argument('-v', '--verbose', default=False, help='verbosity level - 1, 2 or 3')
  parser.add_argument('-d', '--dryrun', default=False, help='Dry Run.  "-dry" will not update database')
  args = parser.parse_args()
  path = vars(args)['path'][0]
  hostname = vars(args)['hostname']
  verbose = vars(args)['verbose']
  dryrun = vars(args)['dryrun']

  today = time.strftime('%Y-%m-%d')
  cum_filesize = 0
  sizebygid = {}
  sizebyuid = {}
  dircount = {}
  filecount = {}
  filesizes = {}
  file_ext = {}
  fileatimes = {}
  filemtimes = {}
  conn = dbconnect.createConnection('storage_usage')

  print("Collecting data for "+path+ " at "+time.ctime());
  for dirpath, dirnames, filenames in os.walk(path):
    """Walks through a file system, and gathers statistics from the os.lstat command
       [4] = uid [5] = gid [6] = size [7] = atime [8] = mtime [9] = ctime"""
    for dir in dirnames:
     if '.svn' not in dirnames or '.svn' not in dir:
      fulldir = os.path.join(dirpath, dir)
      uid, gid, size, atime, mtime, ctime = os.lstat(fulldir)[4:]
      cumulate(sizebygid, gid, size)
      cumulate(filecount, "dirs", 1)
    for file in filenames:
     if '.svn' not in dirpath:
      fullpath = os.path.join(dirpath, file)
      uid, gid, size, atime, mtime, ctime = os.lstat(fullpath)[4:]
      (shortname, ext) = os.path.splitext(file)
      # Create dictionary pairs like { gid1: size, gid2: size...}
      cumulate(sizebygid, gid, size)
      # Create dictionary pairs like { uid: size, count, gid2: size, count, gid3:....}
      cumulate2(sizebyuid, uid, size, 1)
      # Create a dictionary pairs like { files: 1234 }
      cumulate(filecount, "files", 1)
      # Create a dictionary of file extensions like { .xls: [ '73478', '123' ], .... }
      if len(ext) == 0:
        ext = "nil"
      cumulate2(file_ext, ext, size, 1)
      # Create dictionary pairs like:
      # { less than 4K: [ '12', '1234' ], less than 8K: [ '13', '1234' ], ...}
      # Where the first number in the list is bitsize for easier sorting
      #
      if size in range(0, 4096):
        cumulate3(filesizes, "less than 4K",   12, 1, size)
      elif size in range(4096, 8192):
        cumulate3(filesizes, "less than 8K",   13, 1, size)
      elif size in range(8192, 32768):
        cumulate3(filesizes, "less than 32K",  15, 1, size)
      elif size in range(32768, 131072):
        cumulate3(filesizes, "less than 128K", 17, 1, size)
      elif size in range(131072, 262144):
        cumulate3(filesizes, "less than 256K", 18, 1, size)
      elif size in range(262144, 1048576):
        cumulate3(filesizes, "less than 1M",   20, 1, size)
      elif size in range(1048576, 4194304):
        cumulate3(filesizes, "less than 4M",   22, 1, size)
      elif size in range(4194304, 8388608):
        cumulate3(filesizes, "less than 8M",   23, 1, size)
      elif size in range(8388608, 33554432):
        cumulate3(filesizes, "less than 32M",  25, 1, size)
      elif size in range(33554432, 134217728):
        cumulate3(filesizes, "less than 128M", 27, 1, size)
      elif size in range(134217728, 268435456):
        cumulate3(filesizes, "less than 256M", 28, 1, size)
      elif size in range(268435456, 4294967296):
        cumulate3(filesizes, "less than 4G",   32, 1, size)
      elif size >= 4294967296:
        cumulate3(filesizes, "more than 4G",   64, 1, size)
      #
      # Create dictionary pairs like:
      # { 'newer than 1 week': [ '7', '21414' ], newer than 2 weeks': [ '14', '94882' ], ... }
      # Where the first number in the list is number of days for easier sorting
      #
      time_now = int(time.time())
      if atime in range(time_now - 604800, time_now):
        cumulate3(fileatimes, "newer than 1 week",  7, 1, size)
      elif atime in range(time_now - 1209200, time_now - 604800):
        cumulate3(fileatimes, "newer than 2 weeks", 14, 1, size)
      elif atime in range(time_now - 2419200, time_now - 1209200):
        cumulate3(fileatimes, "newer than 4 weeks", 28, 1, size)
      elif atime in range(time_now - 4838400, time_now - 2419200):
        cumulate3(fileatimes, "newer than 8 weeks", 56, 1, size)
      elif atime in range(time_now - 15724800, time_now - 4838400):
        cumulate3(fileatimes, "newer than 6 months", 182, 1, size)
      elif atime in range(time_now - 31557600, time_now - 15724800):
        cumulate3(fileatimes, "newer than 12 months", 365, 1, size)
      elif atime in range(time_now - 63115200, time_now - 31557600):
        cumulate3(fileatimes, "newer than 2 years", 730, 1, size)
      elif atime <= time_now - 63115200:
        cumulate3(fileatimes, "older than 2 years", 731, 1, size)

      if mtime in range(time_now - 604800, time_now):
        cumulate3(filemtimes, "newer than 1 week",  7, 1, size)
      elif mtime in range(time_now - 1209200, time_now - 604800):
        cumulate3(filemtimes, "newer than 2 weeks", 14, 1, size)
      elif mtime in range(time_now - 2419200, time_now - 1209200):
        cumulate3(filemtimes, "newer than 4 weeks", 28, 1, size)
      elif mtime in range(time_now - 4838400, time_now - 2419200):
        cumulate3(filemtimes, "newer than 8 weeks", 56, 1, size)
      elif mtime in range(time_now - 15724800, time_now - 4838400):
        cumulate3(filemtimes, "newer than 6 months", 182, 1, size)
      elif mtime in range(time_now - 31557600, time_now - 15724800):
        cumulate3(filemtimes, "newer than 12 months", 365, 1, size)
      elif mtime in range(time_now - 63115200, time_now - 31557600):
        cumulate3(filemtimes, "newer than 2 years", 730, 1, size)
      elif mtime <= time_now - 63115200:
        cumulate3(filemtimes, "older than 2 years", 731, 1, size)

#
#   Find out if group exists, if not create record
#
  for group, value in sizebygid.items():
    query_string = "SELECT id FROM groups WHERE id = '%s'; " % (group)
    result = dbconnect.dbquery(conn, query_string)
    if verbose != False:
      print("SQL Statement: " +query_string+ "\nResult: " +str(result))
    if result == None:
      try:
        grname = grp.getgrgid(group)[0]
      except KeyError:
        grname = 'unknown'
      values = (group, grname)
      insert_sql = "INSERT into groups (id, groupname) VALUES (%s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
      if verbose != False:
        print("Group " +grname+ " added")
    conn.commit()

#
#   Find out if user exists, if not create record
#
  for user, value in sizebyuid.items():
    query_string = "SELECT id FROM users WHERE id = '%s'; " % (user)
    result = dbconnect.dbquery(conn, query_string)
    if verbose != False:
      print("SQL Statement: " +query_string+ "\nResult: " +str(result))
    if result == None:
      try:
        uname = pwd.getpwuid(user)[0]
      except KeyError:
        uname = 'uk'+str(user)
      values = (user, uname)
      insert_sql = "INSERT into users (id, username) VALUES (%s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
      if verbose != False:
        print("User " +uname+ " added")
    conn.commit()

#
#   Find out if mountpoint exists, if not create record
#
  realhostname = hostname[0]
  query_string = "SELECT id FROM mountpoints WHERE mountpoint = '%s' AND hostname = '%s'; " % (path.strip(), realhostname)
  mpt_id = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(mpt_id))
  if mpt_id == None:
    values = (path.strip(), realhostname)
    insert_sql = "INSERT into mountpoints (mountpoint, hostname) VALUES (%s, %s)"
    if dryrun == False:
      dbconnect.dbexecute(conn, insert_sql, values)
    if verbose != False:
      print("Mountpoint " +path.strip()+ " added")
  conn.commit()
#
#   Find out if today's record exists, if not create record
#
  mountpt_id = (dbconnect.dbquery(conn, query_string)[0])[0]
  print("mountpoint_id = "+str(mountpt_id))
  values = (mountpt_id, today)
  query_string = "SELECT id FROM directory_size WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for gid, bytes in sizebygid.items():
      values = (mountpt_id, today, gid, bytes)
      insert_sql = "INSERT into directory_size (mountpoint_id, date, group_id, bytes) VALUES (%s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
    conn.commit()
  if verbose != False:
    print("directory_size updated")
  dir_count = filecount['dirs']
  file_count = filecount['files']
  values = (mountpt_id, today, dir_count, file_count)
  insert_sql = "INSERT into file_count (mountpoint_id, date, dir_count, file_count) VALUES (%s, %s, %s, %s)"
  if dryrun == False:
    dbconnect.dbexecute(conn, insert_sql, values)
  if verbose != False:
    print("file_count updated")
  conn.commit()
#
#   Insert size_by_user data
#
  values = (mountpt_id, today)
  query_string = "SELECT id FROM size_by_user WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for uid, bytescount in sizebyuid.items():
      bytes = list(bytescount)[0]
      count = list(bytescount)[1]
      values = (mountpt_id, today, uid, bytes, count)
      insert_sql = "INSERT into size_by_user (mountpoint_id, date, user_id, bytes, count) VALUES (%s, %s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
    conn.commit()
  if verbose != False:
    print("size_by_user updated")

#
# Insert file extention data
#
  query_string = "SELECT id FROM file_types WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  if verbose != False:
    print("SQL Statement: " +query_string)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for file_extension, value in file_ext.items():
      values = (mountpt_id, today, file_extension, value[0], value[1])
      insert_sql = "INSERT into file_types (mountpoint_id, date, file_ext, size, count) VALUES (%s, %s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
    if verbose != False:
      print("file_types updated")
  conn.commit()
#
# Insert file size data
#
  query_string = "SELECT id FROM file_sizes WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for file_size_range, value, in filesizes.items():
      values = (mountpt_id, today, file_size_range, value[0], value[1], value[2])
      insert_sql = "INSERT into file_sizes (mountpoint_id, date, file_size_range, bitsize, count, size) VALUES (%s, %s, %s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
      if verbose != False:
        print("file_sizes updated")
    conn.commit()
#
# Insert file atime data
#
  values = (mountpt_id, today)
  query_string = "SELECT id FROM file_atimes WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for file_atime_range, value, in fileatimes.items():
      values = (mountpt_id, today, file_atime_range, value[0], value[1], value[2])
      insert_sql = "INSERT into file_atimes (mountpoint_id, date, file_atime_range, days_old, count, size) VALUES (%s, %s, %s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
      if verbose != False:
        print("file_atimes updated")
    conn.commit()
#
# Insert file mtime data
#
  values = (mountpt_id, today)
  query_string = "SELECT id FROM file_mtimes WHERE mountpoint_id = '%s' AND date = '%s'; " % (mountpt_id, today)
  exists = dbconnect.dbquery(conn, query_string)
  if verbose != False:
    print("SQL Statement: " +query_string+ "\nResult: " +str(exists))
  if exists == None:
    for file_mtime_range, value, in filemtimes.items():
      values = (mountpt_id, today, file_mtime_range, value[0], value[1], value[2])
      insert_sql = "INSERT into file_mtimes (mountpoint_id, date, file_mtime_range, days_old, count, size) VALUES (%s, %s, %s, %s, %s, %s)"
      if dryrun == False:
        dbconnect.dbexecute(conn, insert_sql, values)
      if verbose != False:
        print("file_mtimes updated")
    conn.commit()
