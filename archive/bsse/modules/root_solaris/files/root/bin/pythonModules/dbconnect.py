#!/bin/env python3

import time, sys, psycopg2
sys.path.insert(0, '/root/bin/pythonModules')
import logCollector

def createConnection(database):
  """Defines a database connections string and returms to caller """
  conn_string = "host='bs-dbsvr01' dbname="+database+" user='zfs' password='solaris'"
  try:
    return psycopg2.connect(conn_string)
    logCollector.clearLogState(2)
  except:
    # Get the most recent exception
    exceptionType, exceptionValue, exceptionTraceback = sys.exc_info()
    # Exit the script and print an error telling what happened.
    logCollector.setLogState(2, 'DB - %s' % (str(exceptionValue)).strip()[0:47])
    sys.exit("DataBase createConnection failed!\n ->%s" % (exceptionValue))

#
# Define a function to connect to the database and excecute SQL
#
def dbexecute(conn, statement, par1, par2=None, par3=None):
  """Excecutes an statement on the database. """
  try:
    # conn.cursor will return a cursor object, you can use this cursor to perform queries
    cursor = conn.cursor()
    # execute our Query
    cursor.execute(statement, par1)
    return cursor
    logCollector.clearLogState(2)
  except UnicodeEncodeError:
    print("Got Unicode exception in mountpoint_id " +str(par1[0]))
  except TypeError:
    print("Got Type exception in mountpoint_id " +str(par1[0]))
  except:
    # Get the most recent exception
    exceptionType, exceptionValue, exceptionTraceback = sys.exc_info()
    # Exit the script and print an error telling what happened.
    logCollector.setLogState(2, 'DB - %s' % (str(exceptionValue)).strip())
    sys.exit("DataBase dbexecute failed!\n ->%s" % (exceptionValue))


def dbquery(conn, statement, par1=None, par2=None, par3=None):
  """Excecutes a query on the database and returns the first record"""
  cursor = dbexecute(conn, statement, par1, par2, par3)
  try:
    # retrieve the records from the database
    records = cursor.fetchall()
    cursor.close()
    if not len(records):
      pass
    if (len(records) > 0):
      return records[:]
    logCollector.clearLogState(2)
  except ValueError:
    print("Got Value Error - probably empty")
  except:
    # Get the most recent exception
    exceptionType, exceptionValue, exceptionTraceback = sys.exc_info()
    # Exit the script and print an error telling what happened.
    logCollector.setLogState(2, 'DB - %s' % (str(exceptionValue)).strip())
    sys.exit("Database dbquery failed!\n ->%s" % (exceptionValue))
