# frozen_string_literal: true

class AggregateCsv
  include ConnectAws
  attr_reader :primer

  def initialize(primer = nil)
    @primer = primer
  end

  def create_taxa_results_csv(aws: true)
    return if barcodes.blank?

    aws ? create_taxa_results_csv_aws : create_taxa_results_csv_local
  end

  def create_sample_metadata_csv(aws: true)
    aws ? create_sample_metadata_csv_aws : create_sample_metadata_csv_local
  end

  def fetch_file_list(prefix)
    bucket = s3_resource.bucket(ENV.fetch('S3_BUCKET'))
    bucket.objects(prefix: prefix).map do |item|
      { name: item.key.split(prefix).second.tr('/', ''),
        url: item.presigned_url(:get) }
    end
  end

  def completed_samples_count
    @completed_samples_count ||= Sample.results_completed.count
  end

  private

  def samples_metadata_fields
    %i[
      barcode latitude longitude location gps_precision collection_date
      submission_date field_notes substrate depth habitat
      environmental_features
    ]
  end

  def create_sample_metadata_csv_aws
    obj = s3_object(create_samples_key)
    obj.upload_stream do |write_stream|
      CSV(write_stream) do |csv|
        csv << samples_metadata_fields

        execute(samples_sql).each do |record|
          csv << record.values
        end
      end
    end
  end

  def create_sample_metadata_csv_local
    CSV.open(samples_file_name, 'wb') do |csv|
      csv << samples_metadata_fields

      execute(samples_sql).each do |record|
        csv << record.values
      end
    end
  end

  def create_taxa_results_csv_aws
    obj = s3_object(create_taxa_key)
    obj.upload_stream do |write_stream|
      CSV(write_stream) do |csv|
        csv << ['sum.taxonomy'] + barcodes

        execute(taxa_table_sql).each do |record|
          csv << record.values
        end
      end
    end
  end

  def create_taxa_results_csv_local
    CSV.open(taxa_file_name, 'wb') do |csv|
      csv << ['sum.taxonomy'] + barcodes

      execute(taxa_table_sql).each do |record|
        csv << record.values
      end
    end
  end

  def today
    Time.zone.today.strftime('%Y-%m-%d')
  end

  def taxa_file_name
    "#{today}_#{completed_samples_count}_samples_#{primer.name}.csv"
  end

  def create_taxa_key
    "aggregate_csvs/#{taxa_file_name}"
  end

  def samples_file_name
    "#{today}_#{completed_samples_count}_samples_metadata.csv"
  end

  def create_samples_key
    "aggregate_csvs/#{samples_file_name}"
  end

  def execute(sql)
    PgConnect.execute(sql)
  end

  def taxa_table_sql
    <<~SQL
      SELECT
      "sum.taxonomy", #{select_barcode_sql}
      FROM CROSSTAB(
        'SELECT
        COALESCE(ncbi_nodes.hierarchy_names ->> ''superkingdom'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''phylum'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''class'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''order'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''family'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''genus'', '''') || '';'' ||
        COALESCE(ncbi_nodes.hierarchy_names ->> ''species'', ''''),
        samples.barcode, sum(asvs.count)
        FROM asvs
        JOIN samples ON asvs.sample_id = samples.id
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
        WHERE primer_id = #{primer.id}
        GROUP BY ncbi_nodes.hierarchy_names, samples.barcode
        ORDER BY 1,2',

        '#{barcodes_sql}'
      ) AS foo (
        "sum.taxonomy" text,
        #{columns_sql}
      );
    SQL
  end

  def barcodes
    @barcodes ||= begin
      results = ActiveRecord::Base.connection.exec_query(barcodes_sql)
      results.map { |r| r['barcode'] }
    end
  end

  def barcodes_sql
    <<~SQL
      SELECT DISTINCT(samples.barcode)
      FROM asvs
      JOIN samples ON asvs.sample_id = samples.id
      WHERE primer_id = #{primer.id}
    SQL
  end

  def select_barcode_sql
    barcodes.map do |barcode|
      "COALESCE(\"#{barcode}\", 0) as \"#{barcode}\""
    end.join(',')
  end

  def columns_sql
    barcodes.map do |barcode|
      "\"#{barcode}\" int"
    end.join(',')
  end

  def samples_sql
    <<~SQL
      SELECT barcode, latitude, longitude, location, gps_precision,
      collection_date, submission_date, field_notes,
      substrate_cd AS substrate, depth_cd AS depth, habitat_cd AS habitat,
      array_to_string(environmental_features, '; ') AS  environmental_features
      FROM samples
      WHERE status_cd = 'results_completed'
    SQL
  end
end
