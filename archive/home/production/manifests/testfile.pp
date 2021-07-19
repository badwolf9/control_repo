file { '/tmp/testfile.txt':
    ensure =>present,
    replace => true,
    mode => '0644',
    content => 'holy cow!',
     }