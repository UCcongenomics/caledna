# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module ResearchProjectService
  class PillarPoint
    include CustomPagination
    include ResearchProjectService::PillarPointServices::Intro
    include ResearchProjectService::PillarPointServices::OccurrencesComparison
    include ResearchProjectService::PillarPointServices::GbifSourceComparison
    include ResearchProjectService::PillarPointServices::GbifEdnaComparison
    include ResearchProjectService::PillarPointServices::CommonTaxaMap
    include ResearchProjectService::PillarPointServices::BioticInteractions
    include ResearchProjectService::PillarPointServices::AreaDiversity
    include ResearchProjectService::PillarPointServices::DetectionFrequency
    include ResearchProjectService::PillarPointServices::TaxonomyComparison

    attr_reader :project, :taxon_rank, :sort_by, :params,
                :globi_taxon

    def initialize(project, params)
      @project = project
      rank = params[:taxon_rank]
      @taxon_rank =
        NcbiNode::TAXON_RANKS_PHYLUM.include?(rank) ? rank : 'phylum'
      @sort_by = params[:sort]
      @params = params
      @globi_taxon = params[:taxon]&.tr('+', ' ')
    end

    def gbif_occurrences
      sql = <<-SQL
        SELECT kingdom, species, decimallatitude as latitude,
        decimallongitude as longitude, gbifid as id
        FROM pillar_point.gbif_occurrences
        INNER JOIN research_project_sources
        ON research_project_sources.sourceable_id =
        pillar_point.gbif_occurrences.gbifid
        AND research_project_sources.sourceable_type = 'PpGbifOccurrence'
        WHERE (research_project_sources.research_project_id = #{project.id})
        AND (metadata ->> 'location' != 'Montara SMR')
        AND (kingdom is not null)
      SQL
      conn.exec_query(sql)
    end

    def gbif_occurrences_by_taxa
      taxon = PpGbifOccTaxa.find_by(taxonkey: params[:gbif_id])
      rank = taxon.taxonrank == 'class' ? 'classname' : taxon.taxonrank
      name = taxon.send(rank.to_s)

      sql = <<-SQL
      SELECT gbifid
      FROM research_project_sources
      JOIN pillar_point.gbif_occurrences
      ON research_project_sources.sourceable_id =
        pillar_point.gbif_occurrences.gbifid
      WHERE sourceable_type = 'PpGbifOccurrence'
      AND research_project_id = #{project.id}
      AND metadata ->> 'location' != 'Montara SMR'
      SQL

      sql += if rank == 'order'
               "AND \"order\" = #{conn.quote(name)};"
             else
               "AND #{rank} = #{conn.quote(name)};"
             end

      ids = conn.exec_query(sql).rows.flatten
      PpGbifOccurrence.where(gbifid: ids)
    end

    private

    def combine_taxon_rank_field
      taxon_rank == 'class' ? 'class_name' : taxon_rank
    end

    def gbif_taxon_rank_field
      taxon_rank == 'class' ? 'classname' : taxon_rank
    end

    def conn
      @conn ||= ActiveRecord::Base.connection
    end

    def convert_counts(results)
      counts = {}
      results.to_a.map do |result|
        counts[result['category']] = result['count']
      end
      counts
    end

    def gbif_division_sql
      <<-SQL
        SELECT pillar_point.combine_taxa.kingdom as category, COUNT(*) as count
        #{gbif_common_division_sql}
      SQL
    end

    def gbif_unique_sql
      <<-SQL
        SELECT pillar_point.combine_taxa.kingdom as category,
        COUNT(DISTINCT(source_taxon_id))
        #{gbif_common_division_sql}
      SQL
    end

    def gbif_common_division_sql
      <<-SQL
        FROM pillar_point.gbif_occurrences
        JOIN pillar_point.combine_taxa
          ON pillar_point.combine_taxa.source_taxon_id = pillar_point.gbif_occurrences.taxonkey
          AND (source = 'gbif')
        JOIN research_project_sources
          ON research_project_sources.sourceable_id =
          pillar_point.gbif_occurrences.gbifid
          AND (research_project_sources.sourceable_type = 'PpGbifOccurrence')
          AND (research_project_sources.research_project_id =
          #{conn.quote(project.id)})
          AND (metadata ->> 'location' != 'Montara SMR')
        WHERE pillar_point.combine_taxa.kingdom IS NOT NULL
      SQL
    end

    def taxon_groups
      params['taxon_groups'].try(:downcase)
    end

    def selected_taxon_groups
      taxon_groups.split('|').to_s[1..-2].tr('"', "'")
    end

    def limit
      48
    end

    def count_sql
      <<-SQL
      SELECT COUNT(*)
      FROM pillar_point.globi_requests
      JOIN research_project_sources
      ON research_project_sources.sourceable_id = pillar_point.globi_requests.id
      WHERE research_project_id = #{project.id}
      AND sourceable_type = 'GlobiRequest'
      SQL
    end

    def query_results(sql_string)
      results = conn.exec_query(sql_string)
      results.to_hash
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
