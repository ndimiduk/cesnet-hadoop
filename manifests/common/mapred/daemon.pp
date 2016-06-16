# == Class hadoop::common::mapred::daemon
#
# Mapreduce specific setup. Called from historyserver classes.
#
class hadoop::common::mapred::daemon {

  hadoop::mkdir { '/hdp':
    touchfile => 'mapred-distcache-installed',
    owner     => 'hdfs',
    group     => 'hadoop',
    recursive => true,
  }
  ->
  hadoop::mkdir { "/hdp/apps/${hadoop::properties['hdp.version']}/mapreduce/":
    touchfile => 'mapred-distcache-installed',
    owner     => 'hdfs',
    group     => 'hadoop',
    mode      => '555',
    recursive => true,
  }
  ->
  hadoop::put { "/hdp/apps/${hadoop::properties['hdp.version']}/mapreduce/mapreduce.tar.gz":
    touchfile => 'mapred-distcache-installed',
    source    => '/usr/hdp/current/hadoop-client/mapreduce.tar.gz',
    owner     => 'hdfs',
    group     => 'hadoop',
    mode      => '444',
  }

  if $hadoop::https {
    file { "${hadoop::mapred_homedir}/hadoop.keytab":
      owner  => 'mapred',
      group  => 'mapred',
      mode   => '0640',
      source => $hadoop::https_keytab,
    }
    file { "${hadoop::mapred_homedir}/http-auth-signature-secret":
      owner  => 'mapred',
      group  => 'mapred',
      mode   => '0640',
      source => '/etc/security/http-auth-signature-secret',
    }
    file { "${hadoop::mapred_homedir}/keystore.server":
      owner  => 'mapred',
      group  => 'mapred',
      mode   => '0640',
      source => $hadoop::https_keystore,
    }
  }
}
