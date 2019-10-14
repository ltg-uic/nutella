# require_relative 'components_list'

module Nutella
  # Utility functions to start components
  class FrameworkComponentsStarter
    include PidFile

    def self.start
      FrameworkComponentsStarter.new.start_framework_components
    end

    # Starts all framework components. If order.json is present, components are started
    # in that order.
    # @return [boolean] true if all components are started correctly, false otherwise
    def start_framework_components
      nutella_components_dir = "#{NUTELLA_HOME}framework_components"
      if File.exist? "#{nutella_components_dir}/order.json"
        components_list = JSON.parse IO.read "#{nutella_components_dir}/order.json"
      else
        components_list = ComponentsList.components_in_dir nutella_components_dir
      end
      components_list.each do |component|
        if File.exist? "#{nutella_components_dir}/#{component}/startup"
          unless start_framework_component "#{nutella_components_dir}/#{component}"
            return false
          end
        end
      end
      true
    end


    # Starts the application level bots
    # @return [boolean] true if all bots are started correctly, false otherwise
    def self.start_app_bots( app_id, app_path )
      app_bots_list = Nutella.current_app.config['app_bots']
      bots_dir = "#{app_path}/bots/"
      # If app bots have been started already, then do nothing
      unless Nutella::Tmux.session_exist? Nutella::Tmux.app_bot_session_name app_id
        # Start all app bots in the list into a new tmux session
        tmux = Nutella::Tmux.new app_id, nil
        ComponentsList.for_each_component_in_dir bots_dir do |bot|
          unless app_bots_list.nil? || !app_bots_list.include?( bot )
            # If there is no 'startup' script output a warning (because
            # startup is mandatory) and skip the bot
            unless File.exist?("#{bots_dir}#{bot}/startup")
              console.warn "Impossible to start bot #{bot}. Couldn't locate 'startup' script."
              next
            end
            # Create a new window in the session for this run
            tmux.new_app_bot_window bot
          end
        end
      end
      true
    end


    def self.start_run_bots( bots_list, app_path, app_id, run_id )
      # Create a new tmux instance for this run
      tmux = Nutella::Tmux.new app_id, run_id
      # Fetch bots dir
      bots_dir = "#{app_path}/bots/"
      # Start the appropriate bots
      bots_list.each { |bot| start_run_level_bot(bots_dir, bot, tmux) }
      true
    end


    #--- Private class methods --------------


    # Starts a single framework component
    # @return [boolean] true if the component has been started successfully, false otherwise
    def self.start_framework_component( component_dir )
      pid_file_path = "#{component_dir}/.pid"
      return true if sanitize_pid_file pid_file_path
      # Component is not running and there is no pid file so we try to start it
      # and create a new pid file. Note that the pid file is created by
      # the startup script!
      # Framework components are started without any parameters passed to them because they have
      # full access to config, runlist and framework APIs using 'require_relative'
      command = "#{component_dir}/startup"
      pid = fork
      exec(command) if pid.nil?
      # Give it a second so they can start properly
      sleep 1
      # All went well so we return true
      true
    end
    private_class_method :start_framework_component


    # Starts a run level bot
    def self.start_run_level_bot( bots_dir, bot, tmux )
      # If there is no 'startup' script output a warning (because
      # startup is mandatory) and skip the bot
      unless File.exist?("#{bots_dir}#{bot}/startup")
        console.warn "Impossible to start bot #{bot}. Couldn't locate 'startup' script."
        return
      end
      # Create a new window in the session for this run
      tmux.new_bot_window bot
    end
    private_class_method :start_run_level_bot

  end
  
end
