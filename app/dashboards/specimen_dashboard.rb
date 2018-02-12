require "administrate/base_dashboard"

class SpecimenDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    taxonomic_unit: Field::BelongsTo,
    extraction: Field::BelongsTo,
    hierarchy: Field::HasOne,
    id: Field::Number,
    tsn: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    :hierarchy,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    # :hierarchy,
    :id,
    # :tsn,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    # :hierarchy,
    # :tsn,
  ].freeze

  # Overwrite this method to customize how specimen are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(specimen)
  #   "Specimen ##{specimen.id}"
  # end
end
