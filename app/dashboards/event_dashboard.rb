require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    field_data_project: Field::BelongsTo,
    flyer: Field::ActiveStorageAttachmentField,
    id: Field::Number,
    name: Field::String,
    start_date: Field::DateTime,
    end_date: Field::DateTime,
    description: Field::TextEditorField,
    location: Field::Text,
    contact: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :start_date,
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_data_project,
    :flyer,
    :created_at,
    :updated_at,
  ].freeze


  FORM_ATTRIBUTES = [
    :name,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_data_project,
    :flyer
  ].freeze

  def display_resource(event)
    event.name
  end

  def permitted_attributes
    super + [:flyer]
  end
end