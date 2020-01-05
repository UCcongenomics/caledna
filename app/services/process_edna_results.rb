# frozen_string_literal: true

module ProcessEdnaResults
  def invalid_taxon?(taxonomy_string)
    return true if taxonomy_string == 'NA'
    return true if taxonomy_string.split(';').blank?
    return true if taxonomy_string.split(';', -1).uniq.sort == ['', 'NA']

    parts_count = taxonomy_string.split(';', -1).count
    return true if parts_count < 6
    return true if parts_count > 7
    false
  end

  # rubocop:disable Metrics/MethodLength
  def find_taxon_from_string_phylum(taxonomy_string)
    rank = get_taxon_rank_phylum(taxonomy_string)
    hierarchy = get_hierarchy_phylum(taxonomy_string, rank)

    raise TaxaError, 'rank not found' if rank.blank?
    raise TaxaError, 'hierarchy not found' if hierarchy.blank?

    taxon = find_exact_taxon(hierarchy, rank) || nil
    complete_taxonomy = get_complete_taxon_string(taxonomy_string)
    {
      taxon_hierarchy: taxon.try(:hierarchy),
      taxon_id: taxon.try(:taxon_id),
      rank: rank,
      original_hierarchy: hierarchy,
      complete_taxonomy: complete_taxonomy,
      original_taxonomy_phylum: taxonomy_string
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def find_taxon_from_string_superkingdom(taxonomy_string)
    rank = get_taxon_rank_superkingdom(taxonomy_string)
    hierarchy = get_hierarchy_superkingdom(taxonomy_string, rank)

    raise TaxaError, 'rank not found' if rank.blank?
    raise TaxaError, 'hierarchy not found' if hierarchy.blank?

    taxon = find_exact_taxon(hierarchy, rank) || nil
    {
      taxon_hierarchy: taxon.try(:hierarchy),
      taxon_id: taxon.try(:taxon_id),
      rank: rank,
      original_hierarchy: hierarchy,
      complete_taxonomy: taxonomy_string,
      original_taxonomy_superkingdom: taxonomy_string,
      original_taxonomy_phylum:
        convert_superkingdom_taxonomy_string(taxonomy_string)
    }
  end
  # rubocop:enable Metrics/MethodLength

  def convert_superkingdom_taxonomy_string(string)
    return ';;;;;' if string == ';;;;;;'
    string.gsub(/^.*?;/, '')
  end

  def find_cal_taxon_from_string(string)
    rank = if phylum_taxonomy_string?(string)
             get_taxon_rank_phylum(string)
           else
             get_taxon_rank_superkingdom(string)
           end
    sql = 'original_taxonomy_phylum = ? OR ' \
      'original_taxonomy_superkingdom = ?'
    CalTaxon.where(sql, string, string)
            .where(taxonRank: rank)
            .where(normalized: true).first
  end

  def phylum_taxonomy_string?(string)
    parts = string.split(';', -1)
    if parts.length == 6
      true
    elsif parts.length == 7
      false
    else
      raise TaxaError, "#{string}: invalid taxonomy string"
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_phylum(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;'

    taxa = string.split(';', -1)
    if taxa_present(taxa[5])
      'species'
    elsif taxa_present(taxa[4])
      'genus'
    elsif taxa_present(taxa[3])
      'family'
    elsif taxa_present(taxa[2])
      'order'
    elsif taxa_present(taxa[1])
      'class'
    elsif taxa_present(taxa[0])
      'phylum'
    else
      'unknown'
    end
  end

  def get_hierarchy_phylum(string, rank)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;'

    taxa = string.split(';', -1)
    hierarchy[:species] = taxa[5] if taxa_present(taxa[5])
    hierarchy[:genus] = taxa[4] if taxa_present(taxa[4])
    hierarchy[:family] = taxa[3] if taxa_present(taxa[3])
    hierarchy[:order] = taxa[2] if taxa_present(taxa[2])
    hierarchy[:class] = taxa[1] if taxa_present(taxa[1])
    hierarchy[:phylum] = taxa[0] if taxa_present(taxa[0])

    taxon = find_exact_taxon(hierarchy, rank, skip_kingdom: true)

    kingdom_superkingdom = get_kingdom_superkingdom(taxon)
    hierarchy[:kingdom] = kingdom_superkingdom[:kingdom]
    hierarchy[:superkingdom] = kingdom_superkingdom[:superkingdom]

    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_superkingdom(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;;'

    taxa = string.split(';', -1)
    if taxa_present(taxa[6])
      'species'
    elsif taxa_present(taxa[5])
      'genus'
    elsif taxa_present(taxa[4])
      'family'
    elsif taxa_present(taxa[3])
      'order'
    elsif taxa_present(taxa[2])
      'class'
    elsif taxa_present(taxa[1])
      'phylum'
    elsif taxa_present(taxa[0])
      'superkingdom'
    else
      'unknown'
    end
  end

  def get_hierarchy_superkingdom(string, rank)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;;'

    taxa = string.split(';', -1)
    hierarchy[:species] = taxa[6] if taxa_present(taxa[6])
    hierarchy[:genus] = taxa[5] if taxa_present(taxa[5])
    hierarchy[:family] = taxa[4] if taxa_present(taxa[4])
    hierarchy[:order] = taxa[3] if taxa_present(taxa[3])
    hierarchy[:class] = taxa[2] if taxa_present(taxa[2])
    hierarchy[:phylum] = taxa[1] if taxa_present(taxa[1])
    hierarchy[:superkingdom] = taxa[0] if taxa_present(taxa[0])

    taxon = find_exact_taxon(hierarchy, rank, skip_kingdom: true)

    hierarchy[:kingdom] = get_kingdom(taxon) if taxon

    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # NOTE: adds kingdoms to taxonomy string since test results don't include
  # kingdoms
  def get_complete_taxon_string(string)
    rank = get_taxon_rank_phylum(string)
    hierarchy = get_hierarchy_phylum(string, rank)

    kingdom = hierarchy[:kingdom]
    superkingdom = hierarchy[:superkingdom]

    string = kingdom.present? ? "#{kingdom};#{string}" : ";#{string}"
    string = superkingdom.present? ? "#{superkingdom};#{string}" : ";#{string}"
    string
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def find_sample_from_barcode(barcode, status)
    samples = Sample.where(barcode: barcode)

    if samples.length.zero?
      sample = Sample.create(
        barcode: barcode,
        status_cd: status,
        missing_coordinates: true,
        field_project: FieldProject::DEFAULT_PROJECT
      )

      raise TaxaError, "Sample #{barcode} not created" unless sample.valid?

    elsif samples.all?(&:rejected?) || samples.all?(&:duplicate_barcode?)
      raise TaxaError, "Sample #{barcode} was previously rejected"
    elsif samples.length == 1
      sample = samples.take
      sample.update(status_cd: status)
    else
      valid_samples =
        samples.reject { |s| s.duplicate_barcode? || s.rejected? }

      if valid_samples.length > 1
        raise TaxaError, "multiple samples with barcode #{barcode}"
      end

      sample = valid_samples.first
      sample.update(status_cd: status)
    end
    sample
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def find_exact_taxon(hierarchy, rank, skip_kingdom: false)
    unique_taxon_names = %w[species order class phylum kingdom superkingdom]

    if unique_taxon_names.include?(rank)
      get_unique_taxon(hierarchy, rank)
    elsif rank == 'genus'
      get_genus(hierarchy, skip_kingdom)
    elsif rank == 'family'
      get_family(hierarchy)
    end
  end

  def get_kingdom_superkingdom(taxon)
    return {} if taxon.blank?
    {
      kingdom: get_kingdom(taxon),
      superkingdom: get_superkingdom(taxon)
    }
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def convert_raw_barcode(cell)
    sample = cell.split('_').last
    parts = sample.split('.')

    # NOTE: dot notation. X16S_K0078.C2.S59.L001
    if /^(K\d{4})\.([ABC][12])\./.match?(sample)
      kit = parts.first
      location_letter = parts.second.split('').first
      sample_number = parts.second.split('').second
      "#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K_L_S_. 'X12S_K0124LBS2.S16.L001'
    elsif /^K(\d{1,4})(L[ABC])(S[12])\./.match?(sample)
      match = /^K(\d{1,4})(L[ABC])(S[12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-#{location_letter}-#{sample_number}"

    # NOTE: K_S_L_. 'X12S_K0404S1LA.S1.L001'
    elsif /^K(\d{1,4})(S[12])(L[ABC])\./.match?(sample)
      match = /^K(\d{1,4})(S[12])(L[ABC])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[3]
      sample_number = match[2]
      "K#{kit}-#{location_letter}-#{sample_number}"

    # NOTE: K_S_L_R_. 'X18S_K0403S1LBR1.S16.L001'
    elsif /^K(\d{1,4})(S[12])(L[ABC])(R\d)\./.match?(sample)
      match = /^K(\d{1,4})(S[12])(L[ABC])(R\d)/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[3]
      sample_number = match[2]
      replicate_number = match[4]
      "K#{kit}-#{location_letter}-#{sample_number}-#{replicate_number}"

    # NOTE: K_LS. PITS_K0001A1.S1.L001
    # NOTE: _LS. X16S_11A1.S18.L001
    elsif /^K?\d{1,4}[ABC][12]\./.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K301B1
    # NOTE: X203C1
    # NOTE: 203C1
    elsif /^[KX]?\d{1,4}[ABC][12]$/.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: PP301B1
    elsif /^PP\d{1,4}[ABC][12]$/.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K0401.extneg.S135.L001 or X16S_ShrubBlank1
    elsif /(neg)|(blank)/i.match?(sample)
      nil

    # NOTE: X12S_MWWS_H0.54.S54.L001 or X12S_K0723_A1.10.S10.L001
    elsif /^.*?\.\d+\.S\d+\.L\d{3}$/.match?(cell)
      match = /(.*?)\.\d+\.S\d+\.L\d{3}/.match(cell)
      parts = match[1].split('_')
      if parts.length == 3
        "#{parts[1]}-#{parts[2]}"
      else
        "#{parts[0]}-#{parts[1]}"
      end

    elsif /^K\d{1,4}/.match?(sample)
      raise ImportError, "#{sample}: invalid sample format"
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def form_barcode(raw_string)
    raw_barcode = raw_string.strip

    # handles "K0030 B1"
    if raw_barcode.include?(' ')
      parts = raw_barcode.split(' ')
      kit = parts.first
      location_letter = parts.second.split('').first
      sample_number = parts.second.split('').second
      "#{kit}-L#{location_letter}-S#{sample_number}"

    # handles "K0030B1"
    elsif /^K\d{4}\w\d$/.match?(raw_barcode)
      match = /(K\d{4})(\w)(\d)/.match(raw_barcode)
      kit = match[1]
      location_letter = match[2]
      sample_number = match[3]
      "#{kit}-L#{location_letter}-S#{sample_number}"
    else
      raw_barcode
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def find_canonical_taxon_from_string(taxonomy_string)
    new_string = taxonomy_string.dup
    new_string.gsub!(/;NA;/, ';;') while new_string.include?(';NA;')
    new_string.gsub!(/;NA$/, ';')
    new_string.split(';').last
  end

  private

  # NOTE: lineage is ["id", "name", "rank"]
  def get_kingdom(taxon)
    taxon.lineage.select { |l| l.third == 'kingdom' }.first.try(:second)
  end

  def get_superkingdom(taxon)
    taxon.lineage.select { |l| l.third == 'superkingdom' }.first.try(:second)
  end

  def taxa_present(taxa)
    taxa.present? && taxa != 'NA'
  end

  #  NOTE: family names are unique to phylums
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_family(hierarchy)
    taxon_name = hierarchy[:family].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'family')

    if hierarchy[:phylum].present?
      # NOTE: this code searches nested arrays for name and rank
      # 100 grabs 100 nested arrays from lineage
      # [2,3] grabs 2nd item (name) and 3rd item (rank) from each nested array
      sql = "'{#{hierarchy[:phylum]},phylum}'::text[] <@ lineage[100][2:3]"
      query = query.where(sql)
    else
      sql = "'{phylum}'::text[] <@ lineage[100][2:3]"
      query = query.where.not(sql)
    end

    return if query.size > 1
    query.take
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  #  NOTE: genus names are unique to kingdom, phylum, class, order, family
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_genus(hierarchy, skip_kingdom = false)
    taxon_name = hierarchy[:genus].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'genus')
    if hierarchy[:kingdom].present?
      sql = "'{#{hierarchy[:kingdom]},kingdom}'::text[] <@ lineage[100][2:3]"
      query = query.where(sql)
    elsif skip_kingdom == false
      sql = "'{kingdom}'::text[] <@ lineage[100][2:3]"
      query = query.where.not(sql)
    end

    query = format_lineage_query('phylum', hierarchy, query)
    query = format_lineage_query('class', hierarchy, query)
    query = format_lineage_query('order', hierarchy, query)
    query = format_lineage_query('family', hierarchy, query)

    return if query.size > 1
    query.take
  end
  # rubocop:enable Metrics/MethodLength,  Metrics/AbcSize

  def format_lineage_query(rank, hierarchy, query)
    if hierarchy[rank.to_sym].present?
      sql = "'{#{hierarchy[rank.to_sym]},#{rank}}'::text[] <@ lineage[100][2:3]"
      query.where(sql)
    else
      sql = "'{#{rank}}'::text[] <@ lineage[100][2:3]"
      query.where.not(sql)
    end
  end

  def get_unique_taxon(hierarchy, rank)
    taxon_name = hierarchy[rank.to_sym].downcase
    # NOTE: escape single quotes in sql query by using two single quotes
    taxon_name.gsub!("'", "''") if taxon_name.include?("'")

    taxa = NcbiNode.joins(:ncbi_names)
                   .where("lower(\"name\") = '#{taxon_name}'")
                   .where(rank: rank)
    return if taxa.size > 1
    # NOTE: ".first" calls order on primary key, ".take" does not
    taxa.take
  end
end

class TaxaError < StandardError
end
