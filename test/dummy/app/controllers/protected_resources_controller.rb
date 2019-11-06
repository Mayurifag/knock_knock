# frozen_string_literal: true

class ProtectedResourcesController < ApplicationController
  before_action :authenticate_user

  def index
    head :ok
  end
end
