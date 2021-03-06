# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::CreateRecords do
  let(:dummy_class) { Class.new { extend ImportCsv::CreateRecords } }

  describe '#first_or_create_research_project_source' do
    def subject(sample, type, research_project_id)
      dummy_class.first_or_create_research_project_source(sample, type,
                                                          research_project_id)
    end

    let(:research_project) { create(:research_project) }
    let(:sample) { create(:sample) }

    context 'when ResearchProjectSource does not exist' do
      it 'creates a new ResearchProjectSource' do
        expect { subject(sample.id, 'Sample', research_project.id) }
          .to change(ResearchProjectSource, :count).by(1)
      end
    end

    context 'when ResearchProjectSource does exist' do
      it 'does not create a ResearchProjectSource' do
        create(:research_project_source,
               sourceable: sample,
               research_project: research_project)

        expect { subject(sample.id, 'Sample', research_project.id) }
          .to change(ResearchProjectSource, :count).by(0)
      end
    end
  end

  describe '#create_asv' do
    def subject(attributes)
      dummy_class.create_asv(attributes)
    end

    let(:sample) { create(:sample) }
    let(:taxon) { create(:ncbi_node, asvs_count: 0, taxon_id: 1, ids: [1]) }
    let(:primer) { create(:primer) }
    let(:research_project) { create(:research_project) }
    let(:count) { 10 }
    let(:taxonomy_string) { 'P;C;O;F;G;S' }
    let(:attributes) do
      {
        sample_id: sample.id,
        taxon_id: taxon.taxon_id,
        primer: primer,
        research_project_id: research_project.id,
        count: count,
        taxonomy_string: taxonomy_string
      }
    end

    context 'asv does not already exists' do
      it 'creates asv' do
        expect { subject(attributes) }
          .to change(Asv, :count).by(1)
      end

      it 'creates asv with passed in data' do
        subject(attributes)
        asv = Asv.last

        expect(asv.sample).to eq(sample)
        expect(asv.taxon_id).to eq(taxon.id)
        expect(asv.primer).to eq(primer)
        expect(asv.count).to eq(count)
        expect(asv.research_project).to eq(research_project)
        expect(asv.taxonomy_string).to eq(taxonomy_string)
      end
    end

    context 'asv already exists' do
      it 'creates another asv' do
        create(:asv, sample: sample, taxon_id: taxon.id, primer: primer,
                     count: count, research_project: research_project)

        expect { subject(attributes) }
          .to change(Asv, :count).by(1)
      end
    end
  end
end
