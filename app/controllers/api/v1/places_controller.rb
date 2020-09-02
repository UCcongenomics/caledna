# frozen_string_literal: true

module Api
  module V1
    class PlacesController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def show
        render json: {
          place: place,
          samples: { data: samples }
        }
      end

      def gbif_occurrences
        render json: {
          gbif_occurrences: { data: gbif_data }
        }
      end
        }
      end

      private

      def place_id
        params[:id] || params[:place_id]
      end

      def radius
        radius = params[:radius] || 1000
        conn.quote(radius.to_i)
      end

      def place
        @place ||= begin
          Place
            .select('id', 'latitude', 'longitude', 'geom', 'count(*)')
            .select("ST_Buffer(places.geom::geography, #{radius}) as buffer")
            .joins('LEFT JOIN samples_map ON ST_DWithin ' \
            "(places.geom::geography, samples_map.geom::geography, #{radius})")
            .group('id', 'latitude', 'longitude', 'geom')
            .find(place_id)
        end
      end

      def samples
        @samples ||= begin
          SamplesMap
            .joins('JOIN places ON ST_DWithin (places.geom::geography, ' \
            "samples_map.geom::geography, #{radius})")
            .where('places.id = ?', place_id)
        end
      end

      def gbif_columns
        [
          'gbif_occurrences.gbif_id', 'gbif_occurrences.taxon_rank', 'latitude',
          'longitude', 'kingdom', 'gbif_occurrences.scientific_name as name'
        ]
      end
      def gbif_data
        @gbif_data ||= begin
          if CheckWebsite.caledna_site?
            []
          else
            PourGbifOccurrence
              .joins('JOIN pour.gbif_taxa on gbif_taxa.taxon_id = ' \
              'gbif_occurrences.taxon_id')
              .joins('JOIN places ON ST_DWithin (places.geom::geography, ' \
              "gbif_occurrences.geom::geography, #{radius})")
              .select(gbif_columns)
              .where('places.id = ?', place_id)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
      def edna_basic_kingdom_sql
        sql = <<~SQL
          FROM samples
          JOIN places
            ON ST_DWithin (places.geom::geography, samples.geom::geography, $1)
          JOIN asvs ON samples.id = asvs.sample_id
          JOIN ncbi_nodes_edna ON ncbi_nodes_edna.taxon_id = asvs.taxon_id
          JOIN ncbi_divisions
            ON ncbi_divisions.id = ncbi_nodes_edna.cal_division_id
          WHERE places.id = $2
        SQL

        if CheckWebsite.pour_site?
          sql += " AND research_project_id = #{ResearchProject.la_river.id} "
        end

        sql += <<~SQL
          GROUP BY ncbi_divisions.name
          ORDER BY ncbi_divisions.name
        SQL

        sql
      end
      # rubocop:enable Metrics/MethodLength

      def edna_taxa_sql
        <<~SQL
          SELECT ncbi_divisions.name, COUNT(DISTINCT(asvs.taxon_id))
          #{edna_basic_sql}
        SQL
      end

      def edna_occurrences_sql
        <<~SQL
          SELECT ncbi_divisions.name, COUNT(asvs.taxon_id)
          #{edna_basic_sql}
        SQL
      end

      def edna_taxa
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(edna_taxa_sql, 'q', bindings)
      end

      def edna_occurrences
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(edna_occurrences_sql, 'q', bindings)
      end

      def gbif_basic_sql
        <<~SQL
          FROM places
          JOIN pour.gbif_occurrences
          ON ST_DWithin
            (places.geom::geography, gbif_occurrences.geom::geography, $1)
          JOIN pour.gbif_taxa
            ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
          WHERE places.id = $2
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
      end

      def gbif_taxa_sql
        <<~SQL
          SELECT pour.gbif_taxa.kingdom,
            COUNT(DISTINCT(gbif_occurrences.taxon_id))
          #{gbif_basic_sql}
        SQL
      end

      def gbif_occurrences_sql
        <<~SQL
          SELECT pour.gbif_taxa.kingdom, COUNT(gbif_occurrences.taxon_id)
          #{gbif_basic_sql}
        SQL
      end

      def gbif_taxa
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(gbif_taxa_sql, 'q', bindings)
      end

      def gbif_occurrences
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(gbif_occurrences_sql, 'q', bindings)
      end

      def conn
        ActiveRecord::Base.connection
      end
    end
  end
end
