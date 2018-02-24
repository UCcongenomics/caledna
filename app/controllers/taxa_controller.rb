# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    # TODO: r-enable highlights
    @highlights = Highlight.asv
    @top_taxa = Taxon.includes(:vernaculars).where(taxonID: top_taxa_ids)
  end

  def show
    @taxon = taxon
    @samples = paginated_samples
  end

  private

  def taxon
    @taxon ||= Taxon.includes(:vernaculars).find(params[:id])
  end

  def paginated_samples
    if params[:view]
      Kaminari.paginate_array(samples).page(params[:page])
    else
      samples
    end
  end

  # rubocop:disable Metrics/MethodLength
  def raw_samples
    # https://stackoverflow.com/a/36251296
    # Query postgres jsonb by value

    sql = 'SELECT samples.id, samples.barcode, ' \
    'asvs."taxonID" as "taxonID", taxa."canonicalName", samples.latitude, ' \
    'samples.longitude, field_data_project_id, ' \
    'field_data_projects.name as project_name ' \
    'FROM asvs ' \
    'INNER JOIN taxa ON asvs."taxonID" = taxa."taxonID" ' \
    'INNER JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'INNER JOIN samples ON samples.id = extractions.sample_id ' \
    'INNER JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id ' \
    'where exists (select 1 from jsonb_each_text(taxa.hierarchy) ' \
    "pair where pair.value = '#{params[:id]}');"

    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    groups = raw_samples.group_by { |t| t['id'] }.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('canonicalName', 'taxonID')))
    end
  end

  def top_taxa_ids
    Asv.group('taxonID').order('count(*) DESC').limit(10).pluck(:taxonID)
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
