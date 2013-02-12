require "eventmachine"
module MonitCollectd
  class EmServer
    attr_accessor :service, :debug
    attr_reader :services_collected

    def initialize(interval,service,debug=false)
      @service = service
      @services_collected = {}
      @debug = debug
      @types = { 0 => "Filesystem", 1 => "Directory", 2 => "File", 3 => "Daemon", 4 => "Connection", 5 => "System"  }

      EM.add_periodic_timer(interval) do
        @service.services.each do |service|
          values = @service.get_values service
          unless @services_collected[service].nil? && ( values.empty? || values.service_type.to_i != 3 ) 
            if @services_collected[service].nil? 
               @services_collected[service]= Collectd.monit(service.to_sym)
               @services_collected[service].with_full_proc_stats
            end
            unless values.empty?
              @services_collected[service].uptime(:uptime).gauge = values.uptime.to_i
              @services_collected[service].gauge(:status).gauge = values.status.to_i
              @services_collected[service].gauge(:monitor).gauge = values.monitor.to_i
              @services_collected[service].percent(:cpu).gauge = values.cpu["percenttotal"].to_f * 100
              @services_collected[service].memory(:memory).gauge = values.memory["kilobytetotal"].to_i * 1024
              puts "[#{Time.now}]: Sent uptime: #{values.uptime.to_i}, status: #{values.status.to_i}, monitor: #{values.monitor.to_i}, cpu: #{values.cpu["percenttotal"].to_f * 100}, memory: #{values.memory["kilobytetotal"].to_i * 1024} to collectd for service #{service}" if @debug
            else
              @services_collected[service].uptime(:uptime).gauge = 0.0
              @services_collected[service].gauge(:status).gauge = 0.0
              @services_collected[service].gauge(:monitor).gauge = 0.0
              @services_collected[service].percent(:cpu).gauge = 0.0
              @services_collected[service].memory(:memory).gauge = 0.0
              puts "[#{Time.now}]: Sent uptime, status, monitor, cpu, memory with 0.0 for service #{service}" if @debug
            end
          else
            if @debug && !values.empty? && values.service_type.to_i != 3
              puts "[#{Time.now}]: service #{service} is not a Daemon service but a #{@types[values.service_type.to_i]} service"
            end
          end
        end
      end
    end
  end
end
