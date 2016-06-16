# == Class hadoop::datanode::service
#
class hadoop::datanode::service {
  include ::stdlib

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-hdfs-datanode.conf':
    ensure  => file,
    content => template('hadoop/services/hadoop-hdfs-datanode.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  if has_key($hadoop::props, 'dfs.domain.socket.path') {
    file {$::hadoop::hdfs_socketdir:
      ensure => directory,
      mode   => '0700',
      owner  => $hadoop::hdfs_user,
      group  => 'root',
    }
  }

  if $hadoop::zookeeper_deployed {
    service { $hadoop::daemons['datanode']:
      ensure    => 'running',
      enable    => true,
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
    }
  }
}
