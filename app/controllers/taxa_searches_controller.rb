# frozen_string_literal: true

class TaxaSearchesController < ApplicationController
  include CustomPagination

  def show
    if query
      @matches = matches
      @query = query
    else
      @matches = []
      @query = nil
    end
  end

  def matches
    raw_records = conn.execute(result_sql)
    records = raw_records.map { |r| OpenStruct.new(r) }
    add_pagination_methods(records)
    records
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def result_sql
    <<-SQL
    SELECT taxon_id, canonical_name, rank, alt_names, inaturalist_id, eol_id,
    wikidata_image, temp_image, asvs_count
    FROM (
      SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
      ncbi_nodes.alt_names, inaturalist_id, eol_id, wikidata_image, asvs_count,
      temp_image,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(alt_names, '')) AS doc
      FROM ncbi_nodes
      LEFT JOIN external_resources
      ON external_resources.ncbi_id = ncbi_nodes.taxon_id
      GROUP BY  ncbi_nodes.taxon_id, external_resources.inaturalist_id,
      external_resources.eol_id, external_resources.wikidata_image,
      external_resources.temp_image
    ) as search
    WHERE search.doc @@ plainto_tsquery('simple', #{conn.quote(query)})
    OR search.doc @@ plainto_tsquery('english', #{conn.quote(query)})
    ORDER BY asvs_count DESC
    LIMIT #{limit} OFFSET #{offset}
    SQL
  end

  def count_sql
    <<-SQL
    SELECT count(taxon_id)
    FROM (
      SELECT taxon_id,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(alt_names, '')) as doc
      FROM ncbi_nodes
    ) AS search
    WHERE search.doc @@ plainto_tsquery('simple', #{conn.quote(query)})
    OR search.doc @@ plainto_tsquery('english', #{conn.quote(query)})
    SQL
  end

  def query
    params[:query].try(:downcase)
  end

  def limit
    10
  end
end
