module KnockKnock
  class ApplicationController < ActionController::API
    rescue_from Knock.not_found_exception_class_name, with: :record_invaild

    private

    def record_invaild
      render json: "Record invalid", status: :unprocessable_entity
    end
  end
end
