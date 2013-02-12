require 'monit'
require 'collectd'

module MonitCollectd
  class Interface
    attr_reader :monit, :collectd, :server
    attr_accessor :username, :auth, :monit_host, :monit_port, :ssl, :collectd_host, :collectd_port, :interval, :debug
    attr_writer :password
    
    # Create a new instance of the service class with the given options
    # These options will be passed to access monit and collectd
    #
    # <b>Options:</b>
    # * +monit_host+ - the host for Monit, defaults to +localhost+
    # * +monit_port+ - the Monit port, defaults to +2812+
    # * +ssl+ - should we use SSL for the connection to Monit (default: false)
    # * +auth+ - should authentication be used for Monit, defaults to false
    # * +username+ - username for authentication
    # * +password+ - password for authentication
    # * +collectd_host+ - the host for Collectd, defaults to +localhost+
    # * +collectd_port+ - the Collectd port, defaults to +25826+
    # * +interval+ - The Collectd interval to retrieve data, defaults to +10+
    # * +debug+ - turns on or off debug, defaults to +false+
    def initialize(options = {})
      @monit_host ||= options["monit_host"] ||= "localhost"
      @monit_port ||= options["monit_port"] ||= 2812
      @collectd_host ||= options["collectd_host"] ||= "localhost"
      @collectd_port ||= options["collectd_port"] ||= 25826
      @ssl  ||= options["ssl"] ||= false
      @auth ||= options["auth"] ||= false
      @username = options["username"]
      @password = options["password"]
      @interval ||= options["interval"] ||= 10
      @debug ||= options["debug"] ||= false
      if @debug
        indent = ""
        "[#{Time.now}]:".length.times {indent += " "}
        puts "[#{Time.now}]: values set:"
        puts indent + " * debug: #{@debug} "
        puts indent + " * Monit: "
        puts indent + "   - monit_host: #{@monit_host}"
        puts indent + "   - monit_port: #{@monit_port}"
        puts indent + "   - ssl: #{@ssl}"
        puts indent + "   - auth: #{@auth}"
        puts indent + "   - username: #{@username}"
        puts indent + "   - password: #{@password}"
        puts indent + " * collectd:"
        puts indent + "   - host: #{@collectd_host}"
        puts indent + "   - port: #{@collectd_port}"
        puts indent + "   - interval: #{@interval}"
      end
      @monit = Monit::Status.new :host => @monit_host,
        :port => @monit_port,
        :auth => @auth, 
        :username => @username, 
        :password => @password
      Collectd::use_eventmachine = true
      Collectd.add_server(interval=@interval, addr=@collectd_host, port=@collectd_port)
      puts "[#{Time.now}]: Monit and Collectd initialized"
    end

    # Start the server which will send the datas to Collectd
    def start_collection
      puts "[#{Time.now}]: Starting collection..."
      @server = EmServer.new(@interval, self, @debug)
    end

    # Retrieve all the services of the Monit instance
    def services
      begin
        if @monit.get
          @monit.services.map(&:name)
        else
          puts "[#{Time.now}]: Monit instance didn't give right answer" if @debug
          []
        end
      rescue
        puts "[#{Time.now}]: Error trying to connect to Monit instance" if @debug
        []
      end
    end

    # Retrieve the values of a specific service via the service name
    #
    # <b>Options:</b>
    # * +service+ - the name of the service (ex: 'nginx')
    def get_values service
      begin
        if @monit.get
          index = @monit.services.map(&:name).index(service)
          unless index.nil?
            @monit.services[index]
          else
            puts "[#{Time.now}]: Service #{service} not known by Monit" if @debug
            {}
          end
        else
          puts "[#{Time.now}]: Monit instance didn't give right answer" if @debug
          {}
        end
      rescue
        puts "[#{Time.now}]: Error trying to connect to Monit instance" if @debug
        {}
      end
    end
  end
end
