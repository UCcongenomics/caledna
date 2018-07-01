# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    include ProcessingExtractions

    # rubocop:disable Metrics/AbcSize
    def create_asv(cell, extraction, cal_taxon)
      asv = Asv.where(extraction_id: extraction.id, sample: extraction.sample,
                      taxonID: cal_taxon.taxonID)
               .first_or_create
      raise ImportError, "ASV #{cell}: #{asv.errors}" unless asv.valid?

      primer = convert_header_to_primer(cell)
      return if primer.blank?
      return if asv.primers.include?(primer)
      asv.primers << primer
      asv.save
    end
    # rubocop:enable Metrics/AbcSize

    def create_research_project_extraction(extraction, research_project_id)
      project =
        ResearchProjectExtraction
        .where(extraction: extraction,
               sample: extraction.sample,
               research_project_id: research_project_id)
        .first_or_create

      return if project.valid?
      raise ImportError, 'ResearchProjectExtraction not created'
    end

    def update_extraction_details(extraction, extraction_type_id, row)
      hash = JSON.parse(row).to_h
      update_data = format_update_data(hash, extraction_type_id)
      extraction.update(clean_up_hash(update_data))
      extraction
    end

    def create_cal_taxon(data)
      CalTaxon.create(data)
    end

    private

    def convert_header_to_primer(cell)
      return unless cell.include?('_')
      cell.split('_').first
    end
  end
end

class ImportError < StandardError
end
