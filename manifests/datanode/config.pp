# == Class hadoop::datanode::config
#
class hadoop::datanode::config {
  include stdlib
  contain hadoop::common::config
  contain hadoop::common::hdfs::config
  contain hadoop::common::hdfs::daemon

  $keytab = '/etc/security/keytab/dn.service.keytab'
  $user = 'hdfs'
  $file = '/tmp/krb5cc_dn'
  $principal = "dn/${::fqdn}@${hadoop::realm}"
  # for templates in env/*
  $krbrefresh = $hadoop::features["krbrefresh"]
  $realm = $hadoop::realm

  # ensure proper owner and group
  # (better to enable sticky bit for more protection)
  ensure_resource('file', $hadoop::_hdfs_data_dirs, {
    ensure => directory,
    owner  => 'hdfs',
    group  => 'hadoop',
    mode   => '1755',
  })

  if $hadoop::realm {
    file { $keytab:
      owner => 'hdfs',
      group => 'hdfs',
      mode  => '0400',
      alias => 'dn.service.keytab',
    }

    if $hadoop::features["krbrefresh"] {
      $cron_ensure = 'present'
    } else {
      $cron_ensure = 'absent'
    }
    file { '/etc/cron.d/hadoop-datanode-krb5cc':
      ensure  => $cron_ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      alias   => 'dn-cron',
      content => template('hadoop/cron.erb'),
    }

    if $hadoop::features["krbrefresh"] {
      exec { 'dn-kinit':
        command     => "kinit -k -t ${keytab} ${principal}",
        user        => $user,
        path        => '/bin:/usr/bin',
        environment => [ "KRB5CCNAME=FILE:${file}" ],
        creates     => $file,
      }

      File[$keytab] -> Exec['dn-kinit']
    }
  }

  if $::osfamily == 'RedHat' and !$hadoop::features["krbrefresh"] {
    $env_ensure = 'absent'
  } else {
    $env_ensure = 'present'
  }
  file { $hadoop::envs['datanode']:
    ensure  => $env_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'dn-env',
    content => template('hadoop/env/hdfs-datanode.erb'),
  }
}
