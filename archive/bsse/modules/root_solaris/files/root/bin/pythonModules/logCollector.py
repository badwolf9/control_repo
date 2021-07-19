#!/bin/env python3

import sys, time, os

def setLogState(level, loginfo, logfile=''):
  """ level is 1,2,3 (warn,err,unknown) - see nagios
  The output format is : timestamp:source:level:detailed_logfile:comment
  Call like: setLogState(2, 'Error 96', '/var/log/wotsupdoc.log')
  """
  try:
    with open('/var/log/nagios-collector.log', 'a') as log_file:
      print(os.path.split(sys.argv[0])[1], int(time.time()), level, logfile, loginfo, sep=':', file=log_file)
  except IOError as err:
    print('File error: ' + str(err))

def clearLogState(level):
  """ Call like: clearLogState(1) """
  already_cleared = False
  try:
    with open('/var/log/nagios-collector.log') as log_file:
      for each_line in log_file:
        level, zzz, clear = each_line.split(':')[2:5]
        if level == '1' or level == '2':
          if clear.strip() == 'CLEAR':
            already_cleared = True
          else:
            already_cleared = False
      if already_cleared != True:
        try:
          with open('/var/log/nagios-collector.log', 'a') as log_file:    
            print(os.path.split(sys.argv[0])[1], int(time.time()), level, "", "CLEAR", sep=':', file=log_file)
        except IOError as err:
          print('File error: ' + str(err))
  except IOError as err:
    print('File error: ' + str(err))
