# frozen_string_literal: true

module SamplesHelper
  # NOTE: can't use "l(field) format: :short" because it crashes if field is nil
  def self.common_names(vernaculars, parenthesis = true)
    names = vernaculars
            .select { |v| v.language == 'en' }
            .pluck(:vernacularName)
            .map(&:titleize).uniq
    return if names.blank?

    parenthesis ? "(#{common_names_string(names)})" : common_names_string(names)
  end

  def self.common_names_string(names)
    max = 3
    names.count > max ? "#{names.take(max).join(', ')}..." : names.join(', ')
  end

  def self.kingdom_count(asvs)
    kingdoms =
      %w[Animalia Archaea Bacteria Chromista Fungi Plantae Protozoa Viruses]
    results = {}
    kingdoms.each do |kingdom|
      results[kingdom] =
        asvs.select { |asv| asv.taxon.kingdom == kingdom }.count
    end
    results
  end
end