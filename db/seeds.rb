# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'

  Asv.destroy_all
  Photo.destroy_all
  Extraction.destroy_all
  ExtractionType.destroy_all
  Sample.destroy_all
  Researcher.destroy_all
  FieldDataProject.destroy_all
end

def reset_search
  puts 'reset search...'
  PgSearch::Document.delete_all(searchable_type: 'Sample')
  PgSearch::Multisearch.rebuild(Sample)
end

def seed_projects
  puts 'seeding projects...'

  FactoryBot.create(
    :field_data_project,
    kobo_id: nil,
    name: 'Demo project',
    description: Faker::Lorem.paragraph
  )
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def import_taxonomy_data
  puts 'seeding taxonomy...'
  sql_file = Rails.root.join('db').join('data').join('gbif_data.sql')
  db_config = Rails.configuration.database_configuration[Rails.env]
  host = db_config['host']
  user = db_config['username']
  db = db_config['database']

  cmd = 'psql '
  cmd += "--host #{host} " if host.present?
  cmd += "--username #{user} " if user.present?
  cmd += "#{db} < #{sql_file}"
  exec cmd
end

def import_taxonomy_trees
  puts 'seeding taxonomy trees...'
  sql_file = Rails.root.join('db').join('data').join('taxonomy_trees.sql')
  db_config = Rails.configuration.database_configuration[Rails.env]
  host = db_config['host']
  user = db_config['username']
  db = db_config['database']

  cmd = 'psql '
  cmd += "--host #{host} " if host.present?
  cmd += "--username #{user} " if user.present?
  cmd += "#{db} < #{sql_file}"
  exec cmd
end

def seed_samples(project)
  puts 'seeding samples...'

  FactoryBot.create_list(
    :sample, 15,
    field_data_project: project,
    status: :submitted,
    submission_date: Time.zone.now - 2.months
  )

  FactoryBot.create_list(
    :sample, 4,
    field_data_project: project,
    status: :analyzed,
    submission_date: Time.zone.now - 2.months
  )

  FactoryBot.create_list(
    :sample, 50,
    field_data_project: project,
    status: :results_completed,
    submission_date: Time.zone.now - 2.months
  )

  Sample.all.each_with_index do |sample, i|
    sample.update(
      barcode: "K055#{i}-LC-S2",
      latitude: "37.#{i * i}6783",
      longitude: "-120.#{i * 2}23574"
    )
  end
end

def seed_extractions(processor1, processor2, director)
  puts 'seeding extractions...'

  type_a = FactoryBot.create(:extraction_type, name: 'extraction A')
  type_b = FactoryBot.create(:extraction_type, name: 'extraction B')

  Sample.analyzed.each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :being_analyzed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: type_a,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end

  Sample.results_completed.each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :results_completed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: type_a,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end

  Sample.results_completed.take(5).each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :results_completed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: type_b,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end
end

def seed_asvs
  return if Taxon.count.zero?
  puts 'seeding asv...'

  taxon_count = Taxon.valid.count/100
  ids = []

  rand(1..3).times do
    taxon = Taxon.valid.offset(rand(taxon_count)).take
    ids.push(taxon.taxonID)
  end

  Extraction.all.each do |extraction|
    rand(1..5).times do
      taxon = Taxon.valid.offset(rand(taxon_count)).take
      Asv.create(extraction: extraction, taxonID: taxon.taxonID)
    end
    Asv.create(extraction: extraction, taxonID: ids.sample)
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

if Rails.env.production?
  delete_records
  reset_search

  puts 'seeding people...'
  director = FactoryBot.create(
    :director,
    email: 'director@example.com',
    password: 'password',
    username: 'Director Jane'
  )

  FactoryBot.create(
    :lab_manager,
    email: 'lab_manager@example.com',
    password: 'password',
    username: 'Lab Manager Jane'
  )

  processor1 = FactoryBot.create(
    :sample_processor,
    email: 'sample_processor@example.com',
    password: 'password',
    username: 'Sample Processor Jane'
  )

  processor2 = FactoryBot.create(
    :sample_processor,
    email: 'sample_processor2@example.com',
    password: 'password',
    username: 'Sample Processor Bob'
  )

  project = seed_projects
  seed_samples(project)
  seed_extractions(processor1, processor2, director)
  seed_asvs

  puts 'done seeding'
end

import_taxonomy_data if Taxon.count.zero?
import_taxonomy_trees
