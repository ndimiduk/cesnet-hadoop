# == Class hadoop::historyserver::service
#
# Namenode should be launched first if it is colocated with historyserver
# (just cosmetics, some initial exceptions in logs) (tested on hadoop 2.4.1).
#
# It works OK automatically when using from parent hadoop::service class.
#
class hadoop::historyserver::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-mapreduce-historyserver.conf':
    ensure  => file,
    content => template('hadoop/services/hadoop-mapreduce-historyserver.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  # history server requires working HDFS
  if $hadoop::hdfs_deployed {
    service { $hadoop::daemons['historyserver']:
      ensure    => 'running',
      enable    => true,
      require  => File[$hadoop::mapred_log_dir],
      subscribe => [File['core-site.xml'], File['yarn-site.xml']],
    }

    # namenode should be launched first if it is colocated with historyserver
    # (just cosmetics, some initial exceptions in logs) (tested on hadoop 2.4.1)
    if $hadoop::daemon_namenode {
      include ::hadoop::namenode::service
      Class['hadoop::namenode::service'] -> Class['hadoop::historyserver::service']
    }
  } else {
    service { $hadoop::daemons['historyserver']:
      ensure  => 'stopped',
      enable  => true,
      require => File[$hadoop::mapred_log_dir],
    }
  }
}
