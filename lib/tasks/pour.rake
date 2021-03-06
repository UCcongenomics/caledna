# frozen_string_literal: true

namespace :pour do
  task :fix_pilot_coordinates, [:path] => :environment do |_t, args|
    require 'json'
    path = args[:path]

    data = JSON.parse(File.read(path))
    project = FieldProject.find_by(name: 'Los Angeles River')

    raise 'Cannot file project' if project.blank?

    data.each do |datum|
      puts datum['_id']
      results = Sample.where(field_project: project)
                      .where("(kobo_data ->> '_id')::INTEGER = ?", datum['_id'])

      next if results.blank?

      sample = results.first
      new_note = [
        sample.director_notes,
        "original coordinates: #{datum['latitude']}, #{datum['longitude']}"
      ].compact.join('; ')

      sample.update(latitude: datum['latitude'],
                    longitude: datum['longitude'],
                    director_notes: new_note)
    end
  end

  task add_collection_period_to_pilot: :environment do
    sql = <<-SQL
      UPDATE research_project_sources
      SET metadata = jsonb_set(metadata, '{collection_period}', '"Summer 2019 Pilot"')
      WHERE research_project_id = 7 AND sourceable_type = 'Sample';
    SQL
    conn.exec_query(sql)

    sql = <<-SQL
      UPDATE research_project_sources
      SET metadata = jsonb_set(metadata, '{order}', '1')
      WHERE research_project_id = 7 AND sourceable_type = 'Sample';
    SQL
    conn.exec_query(sql)
  end

  def conn
    ActiveRecord::Base.connection
  end
end
