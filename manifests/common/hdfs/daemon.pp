# == Class hadoop::common::hdfs::daemon
#
# HDFS specific setup. Called from namenode and datanode classes.
#
class hadoop::common::hdfs::daemon {

  # HDP packages don't create log or run dirs
  file { $hadoop::hdfs_log_dir:
    ensure => directory,
    owner  => $hadoop::hdfs_user,
    group  => 'hadoop',
    mode   => '0644',
  }

  file { $hadoop::hdfs_pid_dir:
    ensure => directory,
    owner  => $hadoop::hdfs_user,
    group  => 'hadoop',
    mode   => '0755',
  }

  if $hadoop::https {
    file { "${hadoop::hdfs_homedir}/hadoop.keytab":
      owner  => 'hdfs',
      group  => 'hdfs',
      mode   => '0640',
      source => $hadoop::https_keytab,
    }
    file { "${hadoop::hdfs_homedir}/http-auth-signature-secret":
      owner  => 'hdfs',
      group  => 'hdfs',
      mode   => '0640',
      source => '/etc/security/http-auth-signature-secret',
    }
    file { "${hadoop::hdfs_homedir}/keystore.server":
      owner  => 'hdfs',
      group  => 'hdfs',
      mode   => '0640',
      source => $hadoop::https_keystore,
    }
  }
}
