#Function to get the public host key of a client
function ssh_itsc::gethost_key($arg) >> String
 {
#  $key_domain = ".ethz.ch"
  #Set up a PuppetDB query to get the machine public host key
#  $key_node_query0 = "facts[ value ] {certname = "
#  $key_node_query1 = "  and name = 'sshrsakey'}"
#  $key_node_query = "${key_node_query0}\"${arg}${key_domain}\"${key_node_query1}"
  # test if the machine exists in PuppetDB
#  if  puppetdb_query($key_node_query) != [] {
#    $key_node = puppetdb_query($key_node_query)[0]['value']
#  } else {
#    $key_node = 'Notfound'
#  }
$key_nodearray = split(file("/etc/puppetlabs/code/environments/production/modules/ssh_itsc/files/keys/$arg/key.pub")," ")
$key_node = $key_nodearray[1]
}

