# frozen_string_literal: true

module Admin
  class ApproveSamplesController < Admin::ApplicationController
    def index
      @samples = Sample.where(status_cd: :submitted).page params[:page]
    end
  end
end
