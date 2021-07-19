#!/mnt/itsc/solaris/bin/python3

import sys, os

def file_len(fname):
  try:
    with open(fname) as f:
      for i, l in enumerate(f):
        pass
    return i + 1
  except UnboundLocalError:
    return 0

def iserror(line):
  """Normal line format is - hh:mm:ss dirvish --vault bs-host
     Warning line is 'client undefined' followed by a blank line
     Error line is - 2 lines like:
       dirvish bs-host:default error (12) -- broken pipe
       dirvish error: branch /path/bs-host:default image yyyy-mm-dd failed
     Last line is hh:mm:ss done
  """
  if 'fatal error' in line:
    print(line.strip())
    sys.exit(2)
  return(line.strip())

def iswarn(line):
  if 'client undefined' in line:
    warningmessage = (line.strip())
    return(1, warningmessage)

  if 'failed' in line:
    warningmessage = (line.strip())
    return(1, warningmessage)

  if 'partial transfer' in line:
    warningmessage = (line.strip())
    return(1, warningmessage)

  if 'broken pipe' in line:
    warningmessage = (line.strip())
    return(1, warningmessage)
  return(0)

def isend(line):
  if line[9:13] == 'done':
    print("Dirvish completed successfully :-)")
    sys.exit(0)

if __name__ == '__main__':
  error = 'host'
  warning = []
  linecount = 0
  try:
    with open('/var/log/dirvish/log') as log_file:
      lc = file_len('/var/log/dirvish/log')
      if lc == 0:
        print("Dirvish hasn't run yet")
        sys.exit(1)
      for each_line in log_file:
        linecount = linecount + 1
        try:
          host = error.split()[-1]
        except IndexError:
          pass
        error = iserror(each_line)
        warn = iswarn(each_line)
        if len(str(warn)) > 1:
          warning = host+ " " +warn[1]
      if warning:
        print(warning)
        sys.exit(1)
      isend(each_line)
      print("Dirvish is still running")
      sys.exit(1)
  except IOError as err:
    print('File error: ' + str(err))

