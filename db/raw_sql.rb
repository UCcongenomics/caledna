# frozen_string_literal: true

module RawSql
  def create_ggbn_completed_samples_view
    <<-SQL
      CREATE VIEW ggbn_completed_samples AS
        SELECT samples.*, research_projects.decontamination_method
        FROM samples
        JOIN research_project_sources
        ON research_project_sources.sample_id = samples.id
        JOIN research_projects
        ON research_project_sources.research_project_id = research_projects.id
        WHERE status_cd = 'results_completed';
    SQL
  end
end
