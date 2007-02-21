require 'date'
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ProjectConfigTrackerTest < Test::Unit::TestCase
  include FileSandbox

  def setup
    @sandbox = Sandbox.new
    @tracker = ProjectConfigTracker.new(@sandbox.root)
  end

  def teardown
    @sandbox.clean_up
  end

  def test_config_modifications_should_return_true_if_local_config_file_is_created
    @sandbox.new :file => 'cruise_config.rb'
    assert @tracker.config_modified?
  end

  def test_config_modifications_should_return_true_if_central_config_file_is_created
    @sandbox.new :file => 'work/cruise_config.rb'
    assert @tracker.config_modified?
  end

  def test_config_modifications_should_return_true_if_central_config_file_is_modified
    @tracker.central_mtime = 1.second.ago
    @sandbox.new :file => 'work/cruise_config.rb'
    assert @tracker.config_modified?
  end

  def test_config_modifications_should_return_true_if_local_config_file_is_modified
    @tracker.local_mtime = 1.second.ago
    @sandbox.new :file => 'cruise_config.rb'
    assert @tracker.config_modified?
  end

  def test_config_modifications_should_return_false_if_config_files_not_modified
    assert_false @tracker.config_modified?

    @sandbox.new :file => 'cruise_config.rb'
    @sandbox.new :file => 'work/cruise_config.rb'

    assert @tracker.config_modified?

    @tracker.update_timestamps
    assert_false @tracker.config_modified?
  end

  def test_config_modifications_should_return_true_if_local_config_was_deleted    
    @sandbox.new :file => 'cruise_config.rb'
    @tracker.update_timestamps
    @sandbox.remove :file => 'cruise_config.rb'
    assert @tracker.config_modified?
  end

  def test_config_modifications_should_return_true_if_central_config_was_deleted
    @sandbox.new :file => 'work/cruise_config.rb'
    @tracker.update_timestamps
    @sandbox.remove :file => 'work/cruise_config.rb'    
    assert @tracker.config_modified?
  end

  def test_should_load_configuration_from_work_directory_and_then_root_directory
    begin
      @sandbox.new :file => 'work/cruise_config.rb', :with_contents => '$foobar=42; $barfoo = 12345'
      @sandbox.new :file => 'cruise_config.rb', :with_contents => '$barfoo = 54321'
      @tracker.load_config
      assert_equal 42, $foobar
      assert_equal 54321, $barfoo
    ensure
      $foobar = $barfoo = nil 
    end
  end

end