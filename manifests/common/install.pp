# == Class: hadoop::common::install
#
# Install Hadoop packages used for all nodes.
#
class hadoop::common::install {
  include ::stdlib

  ensure_packages($hadoop::packages_common)

  # HDP packages don't create log or run dirs
  file { $hadoop::hdfs_log_dir:
    ensure => directory,
    mode   => '0644',
    owner  => $hadoop::hdfs_user,
    group  => 'hadoop',
  }
}
