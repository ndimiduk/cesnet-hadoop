# == Class hadoop::journalnode::service
#
# Start Hadoop Journal Node daemon. See also hadoop::journalnode.
#
class hadoop::journalnode::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-hdfs-journalnode.conf':
    ensure  => file,
    content => template('hadoop/services/hadoop-hdfs-journalnode.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  service { $hadoop::daemons['journalnode']:
    ensure    => 'running',
    enable    => true,
    subscribe => [File['core-site.xml'], File['hdfs-site.xml']],
  }
}
