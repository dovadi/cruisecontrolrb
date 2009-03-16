class RailsUpdatedTrigger
  attr_accessor :triggered_project

  def initialize(triggered_project)
    self.triggered_project = triggered_project
    self.triggering_project_name = 'rails'
  end

  def build_necessary?(reasons)
    rails = Projects.find('rails')
    if (rails && rails.source_controle.up_to_date?) || rails.nil?
      false
    else
      reasons << "Triggered by an update of #{@triggering_project_name}"
      true
    end
  end

  def ==(other)
    other.is_a?(SuccessfulBuildTrigger) &&
      triggered_project == other.triggered_project &&
      @triggering_project.name == other.triggering_project_name
  end

  def triggering_project_name
    @triggering_project.name
  end

  def triggering_project_name=(value)
    @triggering_project = Project.new(value.to_s)
  end

end
