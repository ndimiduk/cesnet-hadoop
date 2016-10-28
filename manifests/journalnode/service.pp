# == Class hadoop::journalnode::service
#
# Start Hadoop Journal Node daemon. See also hadoop::journalnode.
#
class hadoop::journalnode::service {

  # HDP packages don't provide service scripts o.O
  file {'/etc/init/hadoop-hdfs-journalnode.conf':
    ensure  => file,
    content => epp('hadoop/services/upstart-hdfs.conf.epp', {
      'daemon'  => 'journalnode',
      'group'   => 'hadoop',
      'user'    => $hadoop::hdfs_user,
      'piddir'  => $hadoop::hdfs_pid_dir,
    }),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service[$hadoop::daemons['journalnode']],
  }

  service { $hadoop::daemons['journalnode']:
    ensure    => 'running',
    enable    => true,
    require   => File[$hadoop::hdfs_log_dir],
    subscribe => [File['core-site.xml'], File['hdfs-site.xml']],
  }
}
