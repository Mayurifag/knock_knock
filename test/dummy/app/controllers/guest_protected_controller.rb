# frozen_string_literal: true

class GuestProtectedController < ApplicationController
  before_action :authenticate_guest

  def index
    head :ok
  end
end
