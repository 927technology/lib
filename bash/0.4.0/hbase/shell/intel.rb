#!/usr/bin/env hbase-jruby

require 'csv'
require 'optparse'
require 'socket'
require 'stringio'

require File.expand_path('/usr/local/lib/bash/0.4.0/hbase/hbase.rb', File.dirname(__FILE__))

def main
  # read files
  # parse configuration file
  eval File.read('/usr/local/etc/sepsis/sepsis.conf')
  
  # objects  
  # create hbase object
  hbase                             = Sepsis::HBase.new

  # variables
  # set error counter
  error_count                       = 0
  
  # set json variable 
  json                              = ""
  
  # backup servers
  backup_servers                    = ""
  count_backup_servers              = 0

  # dead servers
  dead_servers                      = ""
  count_dead_servers                = 0

  # servers
  servers                           = ""
  count_servers                     = 0

  # get my hostname
  json                             += %Q{ "hostname":"#{ Socket.gethostname }", }

  # # get metaserver name
  json                             += %Q{ "metaserver":"#{ hbase.metaserver().to_s }", }

  # # master server
  json                             += %Q{ "master":"#{ hbase.master.to_s.split(',')[0] }", }

  # # backup servers
  hbase.backup().each do | servername | 
    backup_servers                 += "," if count_backup_servers > 0

    backup_servers                 += %Q{ "#{ servername.to_s.split(',')[0] }" }

    count_backup_servers           =+ 1
  end
  json                             += %Q{"backup_masters":[#{ backup_servers }],}

  # dead servers
  hbase.dead().each do | servername | 
    dead_servers                   += "," if count_dead_servers > 0

    dead_servers                   += %Q{ "#{ servername.to_s.split(',')[0] }" }

    count_dead_servers             =+ 1
  end
  json                             += %Q{"dead_servers":[#{ dead_servers }],}

  # all servers
  hbase.servers().each do | servername | 
    servers                        += ", " if count_servers > 0
    
    servers                        += %Q{ "#{ servername.to_s.split(',')[0] }" }

    count_servers                  =+ 1
  end
  json                             += %Q{ "servers":[#{servers}], }

  # # request count
  json                             += %Q{ "request_count":#{ hbase.request_count() }, }

  # # regions count
  json                             += %Q{ "region_count":#{ hbase.regions_count() }, }


  # # in transition count
  json                             += %Q{ "transition_count":#{ hbase.in_transition_count() }, }

  # # error count
  json                             += %Q{ "error_count":#{ error_count } }

  # output json
  puts "{#{json}}"
  

  # regions test - you do not need to move each region as long as the region server is stopped
  # regions = hbase.regions()

  # regions.each do | region_server |
  #   puts region_server
  #   puts "***********************"
  #   region_server.each do | region |
  #     puts region
  #     puts
  #     puts "============================="
  #   end
  
  # end

  # exit hbase shell
  exit

end

main