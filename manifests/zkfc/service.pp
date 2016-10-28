# == Class hadoop::zkfc:service:
#
# This class is meant to be called from hadoop::zkfc.
# It ensures the service is running.
#
class hadoop::zkfc::service {
  # zkfc requires working zookeeper first
  if $hadoop::zookeeper_deployed {

    # HDP packages don't provide service scripts o.O
    file {'/etc/init/hadoop-hdfs-zkfc.conf':
      ensure  => file,
      content => epp('hadoop/services/upstart-hdfs.conf.epp', {
        'daemon'  => 'zkfc',
        'group'   => 'hadoop',
        'user'    => $hadoop::hdfs_user,
        'piddir'  => $hadoop::hdfs_pid_dir,
      }),
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service[$hadoop::daemons['hdfs-zkfc']],
    }

    service { $hadoop::daemons['hdfs-zkfc']:
      ensure    => 'running',
      enable    => true,
      require   => File[$hadoop::hdfs_log_dir],
      subscribe => [File['core-site.xml'], File['hdfs-site.xml']],
    }

    # launch the format only once: on the first (main) namenode
    if $hadoop::zookeeper_hostnames and $hadoop::hdfs_hostname == $::fqdn {
      hadoop::kinit {'hdfs-zkfc-kinit':
        touchfile => 'hdfs-zkfc-formatted',
      }
      ->
      exec {'hdfs-zkfc-format':
        command => 'hdfs zkfc -formatZK',
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        user    => 'hdfs',
        creates => '/var/lib/hadoop-hdfs/.puppet-hdfs-zkfc-formatted',
      }
      ->
      hadoop::kdestroy {'hdfs-zkfc-kdestroy':
        touchfile => 'hdfs-zkfc-formatted',
        touch     => true,
      }
      ->
      Service[$hadoop::daemons['hdfs-zkfc']]
    }
  }
}
