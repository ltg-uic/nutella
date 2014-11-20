require 'core/command'


module Nutella
  class Runs < Command
    @description = "Displays list of all the runs, you can filter by passing a project id"
  
    def run(args=nil)
      # If invoked with "--all" it will show all the runs under this instance of nutella
      if args[0]=="--all"
        displayGlobalRuns
      else
        # Is current directory a nutella prj?
        if !Nutella.current_project.exist?
          return
        end
        displayProjectRuns     
      end
    end
    
    
    private 
    
    
    def displayGlobalRuns
      if Nutella.runlist.empty?
        console.info 'You are not running any projects'
      else
        console.info 'Currently running:'
        Nutella.runlist.to_a.each { |run| console.info " #{run}" }   
      end
    end
    
    
    def displayProjectRuns
      project_name = Nutella.current_project.config["name"]
      runs = Nutella.runlist.to_a project_name
      if runs.empty?
        console.info "Currently running #{runs.length} instances of project #{project_name}"
        return
      end
      printProjectRuns(project_name, runs)
    end
    
    
    def printProjectRuns(project_name, runs)
      console.info "Currently running #{runs.length} instances of project #{project_name}:"
      runs.to_a.each do |run|
        run_id = run.dup
        run_id.slice! "#{project_name}_"
        if run_id.empty?
          console.info " #{project_name}"
        else
          console.info " #{run}" 
        end
      end
    end
    
    
  end
end

