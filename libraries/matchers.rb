if defined?(ChefSpec)
  puts 'defining create_zpool'
  def create_zpool(name)
    ChefSpec::Matchers::ResourceMatcher.new(:zpool, :create, name)
  end
end
