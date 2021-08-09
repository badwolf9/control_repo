#
notify { 'First test of puppet!' : }
# make sure /root/bin exists
file { "/root/bin":
       mode => '755',
       ensure => directory,
       owner => "root",
       group => "root",
     }
echo {'TestMessageNoPath':
  message  => 'Test message',
  withpath => false
}

$mess1 = " === $hostname P7 run (OS : $operatingsystem ($lsbdistrelease) / InstType : $installtype / OS family : $osfamily). ==="

#echo 'Next Message'
#  message => $mess1
#  withpath => false

notify { " $mess1" :  }
