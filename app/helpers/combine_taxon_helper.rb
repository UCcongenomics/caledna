# frozen_string_literal: true

module CombineTaxonHelper
  def self.taxon_string(taxon)
    [
      taxon['superkingdom'], taxon['phylum'], taxon['class_name'],
      taxon['order'],
      taxon['family'], taxon['genus'], taxon['species']
    ].compact.join(', ')
  end

  def self.convert_taxa_string(string)
    taxa_array = convert_raw_combine_taxon(string)
    taxa_array.map do |taxon|
      parts = taxon.split('|')
      {
        id: parts.first,
        taxonomy_string: parts.drop(1).join(', ')
      }
    end
  end

  def self.convert_raw_combine_taxon(string)
    string.delete('{"').delete('{').delete('"}').delete('}').split(',')
  end

  def self.convert_taxa_ids(string)
    taxa_array = convert_raw_combine_taxon(string)
    taxa_array.map do |taxon|
      taxon.split('|').first
    end.join('|')
  end

  def self.vernaculars(taxon)
    ncbi = taxon['ncbi_taxa']
    taxa_array =
      ncbi.delete('{"').delete('{').delete('"}').delete('}').split(',')

      names = taxa_array.flat_map do |taxon|
        id = taxon.split('|').first
        NcbiNode.find(id).vernaculars.map(&:name)
      end
      names.present? ? "(#{names.join(', ')})" : ''
  end
end