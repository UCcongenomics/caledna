# frozen_string_literal: true

require 'administrate/base_dashboard'

class ResearcherDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    email: Field::String,
    username: Field::String,
    orcid: Field::String,
    role_cd: EnumField,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    password: PasswordField,
    password_confirmation: PasswordField,
    active: Field::Boolean
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    email
    username
    role_cd
    active
    updated_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    username
    orcid
    role_cd
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    created_at
    updated_at
    active
  ].freeze

  FORM_ATTRIBUTES = %i[
    email
    username
    orcid
    role_cd
    active
    password
    password_confirmation
  ].freeze

  def display_resource(researcher)
    researcher.username
  end
end
