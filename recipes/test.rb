include_recipe 'zfs_linux'

(0..8).each do |fake_disk|
  bash "create fake_disk#{fake_disk}" do
    user 'root'
    code <<-EOH
    fallocate -l 100M /tmp/zfs-#{fake_disk}
    EOH
    not_if { ::File.exist?("/tmp/zfs-#{fake_disk}") }
  end
end

zpool 'raid0' do
  disks ['/tmp/zfs-5', '/tmp/zfs-6']
end

zpool 'raid10-with-log-mirror' do
  disks ['mirror', '/tmp/zfs-1', '/tmp/zfs-2', 'mirror', '/tmp/zfs-7', '/tmp/zfs-8']
  log_disks ['mirror', '/tmp/zfs-3', '/tmp/zfs-4']
  autoexpand true
  mountpoint 'none'
end
