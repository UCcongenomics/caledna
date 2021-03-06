# frozen_string_literal: true

class PrimerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :id, :forward_primer, :reverse_primer, :reference
end
