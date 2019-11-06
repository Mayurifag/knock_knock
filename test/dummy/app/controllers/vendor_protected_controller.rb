# frozen_string_literal: true

class VendorProtectedController < ApplicationController
  before_action :authenticate_vendor, only: %i[index]
  before_action :some_missing_method, only: %i[show]

  def index
    head :ok
  end

  def show
  end
end
