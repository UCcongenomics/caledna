# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    sequence(:kobo_id) { |n| n }
  end
end
