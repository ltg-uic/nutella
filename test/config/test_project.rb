require 'helper'

module Nutella
  
  class TestProject < MiniTest::Test

    # def setup
    #   Dir.chdir NUTELLA_HOME
    #   Nutella.execute_command( 'new', ['test_project'] )
    #   Dir.chdir "#{NUTELLA_HOME}test_project"
    # end
    #
    #
    # should 'return true if the dir is a nutella project' do
    #   assert Nutella.current_project.exist?
    # end
    #
    # should 'return false if the dir is not a nutella project' do
    #   Dir.chdir NUTELLA_HOME
    #   refute Nutella.current_project.exist?
    # end
    #
    # should 'return the correct version of nutella as read from the project configuration file' do
    #   assert_equal File.open("#{NUTELLA_HOME}VERSION", "rb").read, Nutella.current_project.config['nutella_version']
    # end
    #
    #
    # def teardown
    #   FileUtils.rm_rf "#{NUTELLA_HOME}test_project"
    #   Dir.chdir NUTELLA_HOME
    # end

  end
end