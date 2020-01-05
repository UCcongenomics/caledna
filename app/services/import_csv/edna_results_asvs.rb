# frozen_string_literal: true

module ImportCsv
  module EdnaResultsAsvs
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id, primer)
      delimiter = delimiter_detector(file)
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      barcodes = convert_header_row_to_barcodes(data)
      samples = find_samples_from_barcodes(barcodes)

      if samples[:invalid_data].present?
        message = "#{samples[:invalid_data].join(', ')} not in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      asv_attributes = {
        research_project_id: research_project_id,
        primer: primer
      }
      ImportCsvQueueAsvJob.perform_later(
        data.to_json, barcodes, samples[:valid_data], asv_attributes
      )

      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def queue_asv_job(data_json, barcodes, samples_data, asv_attributes)
      data = JSON.parse(data_json)
      data.each do |row|
        next if row.first == 'sum.taxonomy'

        taxonomy_string = row.first
        next if invalid_taxon?(taxonomy_string)

        cal_taxon = find_cal_taxon_from_string(taxonomy_string)
        next if cal_taxon.blank?

        asv_attributes[:taxonID] = cal_taxon.taxonID
        create_asvs_for_row(row, barcodes, samples_data, asv_attributes)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def convert_header_row_to_barcodes(data)
      data.first.headers.map do |raw_barcode|
        convert_raw_barcode(raw_barcode)
      end
    end


    # rubocop:disable Metrics/MethodLength
    def find_samples_from_barcodes(barcodes)
      invalid_data = []
      valid_data = {}

      barcodes.compact.each do |barcode|
        sample = Sample.approved.find_by(barcode: barcode)
        if sample.present?
          valid_data[sample.barcode] = sample.id
        else
          invalid_data << barcode
        end
      end

      { invalid_data: invalid_data, valid_data: valid_data }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def create_asvs_for_row(row, barcodes, samples_data, asv_attributes)
      barcodes.each.with_index do |barcode, i|
        next if barcode.blank?

        read_count = row[i].to_i
        next if read_count < 1

        sample_id = samples_data[barcode]

        ImportCsvCreateResearchProjectSourceJob
          .perform_later(sample_id, 'Sample',
                         asv_attributes[:research_project_id])

        ImportCsvCreateAsvJob.perform_later(
          asv_attributes.merge(sample_id: sample_id, count: read_count)
        )
      end
    end
  end
end

class ImportError < StandardError
end
