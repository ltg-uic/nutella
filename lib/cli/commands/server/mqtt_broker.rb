require 'docker-api'
require 'socket'
require 'config/config'

module Nutella
  class MQTTBroker

    def self.start
      MQTTBroker.new.start_internal_broker
    end

    def self.stop
      MQTTBroker.new.stop_internal_broker
    end
    
    def start_internal_broker
      # Check if the broker has been started already
      return true if broker_started? || broker_started_unsupervised?
      # Broker is not running so we try to start it
      begin
        start_broker  
      rescue
        return false
      end
      # Wait until the broker is up
      wait_for_broker
      true
    end

    def stop_internal_broker
      # Find the broker's container
      begin
        c = Docker::Container.get(broker_container_name)
      rescue Docker::Error::NotFoundError
        # There is no container so the broker 
        # is definitely not runnning, we're done
        return true
      end
      # Try to stop the broker
      begin
        c.stop
        c.delete(force: true)
      rescue
        return false
      end
      true
    end
  
    private

    def broker_container_name 
      @broker_container_name ||= 'mqtt_broker'
    end

    # Checks if the broker is running already
    # @return [boolean] true if there is a container for the broker running already
    def broker_started?
      begin
        c = Docker::Container.get(broker_container_name)
        return c.info['State']['Running']
      rescue Docker::Error::NotFoundError
        return false
      end
      true
    end

    # Checks if port 1883 (MQTT broker port) is free
    # or some other service is already listening on it
    # @return [boolean] true if there is no broker listening on port 1883, false otherwise
    def broker_started_unsupervised?
      begin
        s = TCPServer.new('0.0.0.0', 1883)
        s.close
      rescue
        return true
      end
      false
    end

    # Starts the broker using docker
    def start_broker
      # Remove any other containers with the same name to avoid conflicts
      begin
        old_c = Docker::Container.get(broker_container_name)
        old_c.delete(force: true)
      rescue Docker::Error::NotFoundError
        # If the container is not there we just proceed
      end
      # Try to create and start the container for the broker
      Docker::Container.create(
        'Image': 'matteocollina/mosca:v2.3.0',
        'name': broker_container_name,
        'Detach': true,
        'HostConfig': {
          'PortBindings': { 
            '1883/tcp': [{ 'HostPort': '1883'}],
            '80/tcp': [{ 'HostPort': '1884'}]
          },
          'Binds': ["#{Config.file['home_dir']}broker:/db"],
          'RestartPolicy': {'Name': 'unless-stopped'}
        }
      ).start
    end

    # Checks if there is connectivity to localhost:1883. If not,
    # it waits 1/4 second and then tries again
    def wait_for_broker
      begin
        s = TCPSocket.open('localhost', 1883)
        s.close
      rescue Errno::ECONNREFUSED
        sleep 0.25
        wait_for_broker
      end
    end

  end
end