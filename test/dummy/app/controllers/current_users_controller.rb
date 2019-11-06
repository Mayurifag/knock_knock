# frozen_string_literal: true

class CurrentUsersController < ApplicationController
  def show
    if current_user
      head :ok
    else
      head :not_found
    end
  end
end
