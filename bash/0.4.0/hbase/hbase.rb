require File.expand_path('dependancies.rb', File.dirname(__FILE__))

module Sepsis
  class HBase

    # methods
      public
        def backup()
          @admin.getClusterStatus().getBackupMasters()
        end

        def backup_count()
          @admin.getClusterStatus().getBackupMasters().length
        end

        def dead()
          @admin.getClusterStatus().getDeadServerNames()
        end

        def dead_count()
          @admin.getClusterStatus().getDeadServerNames().length
        end

        # def in_transition()
        #   @admin.getClusterStatus().getRegionStatesInTransition()
        # end

        def is_metaserver(hostname)
          if @metaserver == hostname
            true
          else
            false
          end
        end
        
        def in_transition_count()
          @admin.getClusterStatus().to_s.split("\n").last(1).join("").to_s.split(": ")[1]
        end

        def master()
          @admin.getClusterStatus().getMaster()
        end
        
        def metaserver()
          @metaserver
        end

        def metaserver_count() 
          @metaserver.length
        end

        def request_count()
          @admin.getClusterStatus().getRequestsCount()
        end
        
        def regions()
          @regions
        end
        
        def servers()
          @servers
        end

        def servers_count()
          @servers.length
          # @servers.length
        end

        def serverstatus()
          @admin.getClusterStatus()
        end
          
        def regions_count()
          @admin.getClusterStatus().getRegionsCount()
        end

        def regionserver(verb)
          # need commands to populate this.
          case verb
            when "start"
              system("echo start > /dev/null")
            when "stop"
              system("echo stop > /dev/null")
            when "status"
              system("echo status > /dev/null")
          end
        end

      # end public
        
      private
        # constructor
        def initialize()
          # create hbase configuration object
          config = HBaseConfiguration.create()

          # no prefetch
          config.setInt('hbase.client.prefetch.limit', 1)

          # Make a config that retries at short intervals many times
          config.setInt('hbase.client.pause', 500)
          config.setInt('hbase.client.retries.number', 100)
          
          # config
          @connection                 = ConnectionFactory::createConnection(config)
          @admin                      = @connection.getAdmin()

          # get running state
          get_metaserver(config)
          get_servers()
          get_regions()
          # get_regions(config, @servers)
        end

        # functions
          def get_metaserver(config)
            # config = get_configuration
            zkw                         = ZooKeeperWatcher.new(config, nil, nil)
            locator                     = MetaTableLocator.new
            server_name                 = locator.get_meta_region_location(zkw)
            
            # end connection to zookeeper
            zkw.close
            
            @metaserver                 = server_name.get_hostname
          end
          
          def get_regions()
            @regions = Array.new
            count = 0

            @servers.each do | servername |
              parts = servername.split(',')
              @regions[count] = @admin.getOnlineRegions(ServerName::valueOf(parts[0], parts[1].to_i, parts[2].to_i))
            
              count += 1
            end

          end

          def get_servers()
            @servers = @admin.getClusterStatus().getServers().collect { |server| server.getServerName() }
          end
        # end functions

      # end private
    # end methods
  end
end