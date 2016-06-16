# == Class hadoop::resourcemanager::service
#
# This class is meant to be called from hadoop.
# It ensure the services are running.
#
class hadoop::resourcemanager::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-yarn-resourcemanager.conf':
    ensure  => file,
    content => template('hadoop/services/hadoop-yarn-resourcemanager.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  # HDP packages don't create log or run dirs
  file { $hadoop::yarn_log_dir:
    ensure => directory,
    mode   => '0644',
    owner  => $hadoop::yarn_user,
    group  => 'hadoop',
  }

  if $hadoop::zookeeper_deployed {
    service { $hadoop::daemons['resourcemanager']:
      ensure    => 'running',
      enable    => true,
      subscribe => [File['core-site.xml'], File['yarn-site.xml']],
    }

    # namenode should be launched first if it is colocated with resourcemanager
    # (just cosmetics, some initial exceptions in logs) (tested on hadoop 2.4.1)
    if $hadoop::daemon_namenode {
      include ::hadoop::namenode::service
      Class['hadoop::namenode::service'] -> Class['hadoop::resourcemanager::service']
    }

    # any datanode needs to be launched when state-store feature is enabled,
    # so rather always start it when colocated with resource manager
    if $hadoop::daemon_datanode and ($hadoop::features['rmstore'] or $hadoop::features['aggregation']) {
      include ::hadoop::datanode::service
      Class['hadoop::datanode::service'] -> Class['hadoop::resourcemanager::service']
    }
  } else {
    service { $hadoop::daemons['resourcemanager']:
      ensure => 'stopped',
      enable => true,
    }
  }
}
