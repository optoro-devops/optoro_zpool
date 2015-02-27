describe 'zpool provider' do
  let(:node) { Chef::Node.new }

  let(:run_context) { double(:run_context, node: node) }

  let(:new_resource) do
    double(:new_resource, name: 'zpool',
        disks: ['/tmp/zfs-1', '/tmp/zfs-2'],
        updated_by_last_action: false)
  end

  let(:provider) do
    Chef::Provider::Zpool.new(new_resource, run_context)
  end

  let(:zpool) {double(users: { keys: {} } )}

  it 'creates a raid0 zpool' do
    allow(Chef::Provider::Zpool).to receive(:new)
      .with({disks:['/tmp/zfs-1', '/tmp/zfs-2']})
      .and_return(zpool)

    expect(github.zpool).to receive(:create)
      .with({ name: 'zpool', disks: ['/tmp/zfs-1', '/tmp/zfs-2'] })
      .and_return(true)

    provider.action_create
  end
end

