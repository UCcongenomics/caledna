# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include BatchData

      def index
        taxa = ::Taxon.where('lower("canonicalName") like ?', "#{query}%")
                      .limit(10)

        options = {}
        render json: ::TaxonSerializer.new(taxa, options).serialized_json
      end

      def show
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count,
          base_samples: BasicSampleSerializer.new(Sample.results_completed)
        }, status: :ok
      end

      private

      def query
        params[:query].downcase
      end

      end

      # rubocop:disable Metrics/MethodLength
      def raw_samples
        sql = 'SELECT DISTINCT samples.id, samples.barcode, ' \
          'samples.latitude, samples.longitude, ' \
          'status_cd as status ' \
          'FROM asvs ' \
          'JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" ' \
          'JOIN samples ON samples.id = asvs.sample_id ' \
          'WHERE latitude IS NOT NULL AND longitude IS NOT NULL ' \
          "AND ids @> '{#{conn.quote(params[:id].to_i)}}' "

        @raw_samples ||= conn.exec_query(sql)
      end
      # rubocop:enable Metrics/MethodLength

      def samples
        @samples ||= raw_samples.map { |r| OpenStruct.new(r) }
      end

      def conn
        @conn ||= ActiveRecord::Base.connection
      end
    end
  end
end
