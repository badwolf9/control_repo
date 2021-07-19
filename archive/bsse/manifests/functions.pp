##
##      Puppet D-BSSE Framework documentation
##
# WIKI START D-BSSE Puppet 4 Framework::Puppet config functions.pp
## OS :: Redhat;Ubuntu
######################################
#
# h3. Purpose of the file
#
# * Contains some puppet wide used functions
#
# h3. See also
#
#
#	This file contains several functions used for other receipes etc...
#       If present is passed with a line of text and a filename then the present case
#       will append the line of text to the file if the line of text is not already present in that file.
#
#       If absent is passed then the line is deleted in the file if it exists.
#
#       In this manner a config file can be kept consistent across multiple puppet runs (idempotent!!).
#  ----------------  Question - is this still used????   -----------------
#  MJF 2017 07 27
###########
# WIKI STOP

define line($file, $line, $ensure = present) 
{
   case $ensure {
      default : { err ( "unknown ensure value ${ensure}" ) }
      present: {
         exec { "/bin/echo '${line}' >> '${file}'":
            unless => "/bin/grep -qFx '${line}' '${file}'"
         }
      }
      absent: {
         exec { "/usr/bin/perl -ni -e 'print unless /\\Q${line}\\E/' '${file}'":
            onlyif => "/bin/grep -qFx '${line}' '${file}'"
         }
      }
   }
}
