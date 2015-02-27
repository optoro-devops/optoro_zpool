require 'spec_helper'

describe zfs('raid0') do
  it { should exist }
end

# ensure two disks are present
describe command('zpool iostat -v raid0 | grep -c -e \'zfs-[[:digit:]]\'') do
  its(:stdout) { should match '2' }
end

describe zfs('raid10-with-log-mirror') do
  it { should exist }
  it { should have_property 'mountpoint' => 'none', 'compression' => 'off', 'atime' => 'on' }
end

# ensure the raid10 has been created
describe command('zpool iostat -v raid10-with-log-mirror | grep -A6 raid10-with-log-mirror | grep -c -e \'[[:space:]]mirror\|zfs\'') do
  its(:stdout) { should match '6' }
end

# ensure the log mirror has been created
describe command('zpool iostat -v raid10-with-log-mirror | grep -A2 logs | grep -c mirror') do
  its(:stdout) { should match '1' }
end

# ensure autoexpand is turned on
describe command('zpool list -H -o autoexpand raid10-with-log-mirror') do
  its(:stdout) { should match 'on' }
end
