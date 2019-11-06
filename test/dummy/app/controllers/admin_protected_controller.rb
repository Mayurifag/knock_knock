# frozen_string_literal: true

class AdminProtectedController < ApplicationController
  before_action :authenticate_admin

  def index
    head :ok
  end
end
