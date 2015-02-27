optoro\_zpool Cookbook
========================

This is a resource cookbook.  Including it in your metadata.rb file will allow you to access to the `zpool` resouce.

  This simply provides a the resource for interacting with zpools. You will need to have ZFS already installed.  See `optoro_zfs`, `zfs`, or `zfs_linux` cookbooks.


Examples!

###RAID0
```
zpool 'raid0' do
  disks ['/dev/sdb','/dev/sdc']
end
```

###RAID1
```
zpool 'raid10' do
  disks ['mirror', '/dev/sdb', '/dev/sdc']
end
```

###RAID10 w/ ZIL 
```
zpool 'raid10' do
  disks ['mirror', '/dev/sdb', '/dev/sdc', 'mirror', '/dev/sdd', '/dev/sde']
  log_disks ['/dev/sdf']
end
```

###RAIDZ w/ ZIL mirror & Cache
```
zpool 'raidz' do
  disks ['mirror', '/dev/sdb', '/dev/sdc', '/dev/sdd']
  log_disks ['mirror', '/dev/sde', '/dev/sdf']
  cache_disks ['/dev/sdg']
end
```

###Optional Attributes

Attribute        | Description |Type | Default
-----------------|-------------|-----|--------
mountpoint       | Aboslute path to where the zpool should be mounted | String | zpool.name
autoexpand       | Whether or not to expand the zpool when a new disk is introduced | Boolean | false
force            | Forces the destruction or creation of a zpool | Boolean | false
ashift           | Sets the ashift for a pool | Integer | 0 (automatic detection)
```
