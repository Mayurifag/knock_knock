# frozen_string_literal: true

class CustomUnauthorizedEntityController < ApplicationController
  before_action :authenticate_user

  def index
    head :ok
  end

  private

  def unauthorized_entity(_entity)
    head :not_found
  end
end
