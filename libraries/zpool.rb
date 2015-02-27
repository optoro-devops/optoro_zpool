require 'chef/resource'
require 'chef/provider'
require 'chef/mixin/shell_out'

class Chef
  class Resource
    # Zpool Resouces
    class Zpool < Chef::Resource
      identity_attr :name

      def initialize(name, run_context = nil)
        super
        @resource_name = :zpool
        @provider = Chef::Provider::Zpool
        @action = :create
        @allowed_actions.push(:create,:destroy)
        @name = name
      end

      def action=(arg = nil)
       set_or_return(:action, arg, :kind_of => [Symbol])
      end

      def disks(arg = nil)
        set_or_return(:disks, arg, :kind_of => [Array], :required => true, :default => nil)
      end

      def info(arg = nil)
        set_or_return(:info, arg, :kind_of => [Mixlib::ShellOut], :default => nil)
      end

      def state(arg = nil)
        set_or_return(:state, arg, :kind_of => [String], :default => nil)
      end

      def force(arg = nil)
        set_or_return(:force, arg, :kind_of => [TrueClass, FalseClass], :default => false)
      end

      def recursive(arg = nil)
        set_or_return(:recursive, arg, :kind_of => [TrueClass, FalseClass], :default => false)
      end

      def ashift(arg = nil)
        set_or_return(:ashift, arg, :kind_of => [Integer], :default => 0)
      end

      def cache_disks(arg = nil)
        set_or_return(:cache_disks, arg, :kind_of => [Array], :default => nil)
      end

      def log_disks(arg = nil)
        set_or_return(:log_disks, arg, :kind_of => [Array], :default => nil)
      end

      def mountpoint(arg = nil)
        set_or_return(:mountpoint, arg, :kind_of => [String], :default => name)
      end

      def autoexpand(arg = nil)
        set_or_return(:autoexpand, arg, :kind_of => [TrueClass, FalseClass], :default => false)
      end
    end
  end
end

class Chef
  class Provider
    # Zpool Provider
    class Zpool < Chef::Provider

      include Chef::Mixin::ShellOut

      def whyrun_supported?
        true
      end

      def load_current_resource
        @zpool ||= Chef::Resource::Zpool.new(new_resource.name)

        zpool_param_names = %w(name disks log_disks cache_disks mountpoint autoexpand)

        zpool_param_names.each do |param_name|
          @zpool.send(param_name, new_resource.send(param_name))
        end

        @zpool.info(info)
        @zpool.state(state)

      end

      def zpool_add(disk)
        converge_by("Adding #{disk} to pool #{@zpool.name}") do
          shell_out!("zpool add #{args_from_resource_add(@new_resource)} #{@zpool.name} #{disk}")
        end
      end

      def zpool_create
        converge_by("Creating zpool #{@zpool.name}") do
          zpool_command = "zpool create #{args_from_resource_create(@new_resource)} #{@zpool.name} #{@zpool.disks.join(' ')}"
          zpool_command << " log #{@zpool.log_disks.join(' ')}" unless @zpool.log_disks.nil?
          zpool_command << " cache #{@zpool.cache_disks.join(' ')}" unless @zpool.cache_disks.nil?
          shell_out!(zpool_command)
        end
      end

      def zpool_destroy
       converge_by("Destroying zpool #{@zpool.name}") do
         shell_out!("zpool destroy #{args_from_resource_add(@new_resource)} #{@zpool.name}")
       end
      end

      def action_create
        if created?
          if online?
            @zpool.disks.each do |disk|
              short_disk = disk.split('/').last
              next if vdevs.include?(disk) || vdevs.include?(short_disk)
              zpool_add(disk)
            end
          else
            Chef::Log.warn("Zpool #{@zpool.name} is #{@zpool.state}")
          end
        else
          zpool_create
        end
      end

      def action_destroy
        if created?
          zpool_destroy
        end
      end

      private

      def args_from_resource_add(new_resource)
        args = []
        args << '-f' if new_resource.force
        args << '-r' if new_resource.recursive

        # Properties
        args << '-o'
        args << format('ashift=%s', new_resource.ashift)

        args.join(' ')
      end

      def args_from_resource_create(new_resource)
        args = args_from_resource_add(new_resource).split(' ')

        if new_resource.name == new_resource.mountpoint
          args << "-m /#{new_resource.mountpoint}"
        else
          args << "-m #{new_resource.mountpoint}"
        end

        args << "-o autoexpand=on" if new_resource.autoexpand

        args.join(' ')
      end

      def created?
        @zpool.info.exitstatus.zero?
      end

      def state
        @zpool.info.stdout.chomp
      end

      def info
        shell_out("zpool list -H -o health #{@zpool.name}")
      end

      def vdevs
        @vdevs ||= shell_out("zpool list -v -H #{@zpool.name}").stdout.lines.map do |line|
          next unless line.chomp =~ /^[\t]/
          line.chomp.split("\t")[1]
        end.compact
        @vdevs
      end

      def online?
        @zpool.state == 'ONLINE'
      end

    end
  end
end
