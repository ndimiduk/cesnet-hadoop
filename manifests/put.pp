# == Define hadoop::put
#
# copy file to HDFS.
#
# === Parameters
#
# [*(title)*]
#   The name of the unqualified HDFS path is in the title of the resource instance.
#
# [*touchfile*] (required)
# [*source*] (required)
# [*owner*] = undef
# [*group*] = undef
# [*mode*] = undef
# [*recursive*] = false
#
# === Requirement
#
# * working HDFS
# * configured local HDFS client
# * User['hdfs']
#
define hadoop::put($touchfile, $source, $owner = undef, $group = undef, $mode = undef, $recursive = false) {
  include ::hadoop::common::hdfs::config

  $dest = $title
  $env = [ "KRB5CCNAME=FILE:/tmp/krb5cc_nn_puppet_${touchfile}" ]
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  $puppetfile = "/var/lib/hadoop-hdfs/.puppet-${touchfile}"

  if ($recursive) {
    $chown_args=' -R'
  } else {
    $chown_args=''
  }

  if $hadoop::zookeeper_deployed {
    # put
    exec { "hadoop-put:${dest}":
      command     => "hdfs dfs -put ${source} ${dest}",
      path        => $path,
      environment => $env,
      unless      => "hdfs dfs -test -e ${dest}",
      user        => 'hdfs',
      creates     => $puppetfile,
      require     => File['hdfs-site.xml'],
    }

    # ownership
    if $owner and $owner != '' or $group and $group != '' {
      exec { "hadoop-chown:${dest}":
        command     => "hdfs dfs -chown${chown_args} ${owner}:${group} ${dest}",
        path        => $path,
        environment => $env,
        user        => 'hdfs',
        creates     => $puppetfile,
      }
      Exec["hadoop-put:${dest}"] -> Exec["hadoop-chown:${dest}"]
    }

    # mode
    if $mode and $mode != '' {
      exec { "hadoop-chmod:${dest}":
        command     => "hdfs dfs -chmod ${mode} ${dest}",
        path        => $path,
        environment => $env,
        user        => 'hdfs',
        creates     => $puppetfile,
      }
      Exec["hadoop-put:${dest}"] -> Exec["hadoop-chmod:${dest}"]
    }
  }
}
