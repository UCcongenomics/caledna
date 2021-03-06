# frozen_string_literal: true

class ResearchProjectSource < ApplicationRecord
  belongs_to :sourceable, polymorphic: true
  belongs_to :research_project
  belongs_to :sample, optional: true

  scope :cal, -> { where(sourceable_type: 'Sample') }
  scope :gbif, -> { where(sourceable_type: 'PpGbifOccurrence') }
end
