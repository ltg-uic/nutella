require_relative 'meta/run_command'

module Nutella
  class Dependencies < RunCommand
    @description = 'Installs the dependencies for all components in the application'
    
    def run(args=nil)
      compile_and_dependencies 'dependencies', 'Installing dependencies for', 'dependencies installed'
    end
    
  end
end