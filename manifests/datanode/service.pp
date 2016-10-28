# == Class hadoop::datanode::service
#
class hadoop::datanode::service {
  include ::stdlib

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-hdfs-datanode.conf':
    ensure  => file,
    content => epp('hadoop/services/upstart-hdfs.conf.epp', {
      'daemon'  => 'datanode',
      'group'   => 'hadoop',
      'user'    => $hadoop::hdfs_user,
      'piddir'  => $hadoop::hdfs_pid_dir,
    }),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service[$hadoop::daemons['datanode']],
  }

  if $hadoop::zookeeper_deployed {
    service { $hadoop::daemons['datanode']:
      ensure    => 'running',
      enable    => true,
      require  => File[$hadoop::hdfs_log_dir],
      subscribe => [File['core-site.xml'], File['hdfs-site.xml']],
    }

    if $hadoop::daemon_namenode {
      include ::hadoop::namenode::service
      Class['hadoop::namenode::service'] -> Class['hadoop::datanode::service']
    }
  } else {
    service { $hadoop::daemons['datanode']:
      ensure => 'stopped',
      enable => true,
      require  => File[$hadoop::hdfs_log_dir],
    }
  }
}
