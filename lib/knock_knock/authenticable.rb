# frozen_string_literal: true

module KnockKnock::Authenticable
  def authenticate_for(entity_class)
    getter_name = "current_#{entity_class.to_s.parameterize.underscore}"
    define_current_entity_getter(entity_class, getter_name)
    public_send(getter_name)
  end

  private

  def token
    params[:token] || token_from_request_headers
  end

  def method_missing(method, *args)
    prefix, entity_name = method.to_s.split("_", 2)
    case prefix
    when "authenticate"
      unauthorized_entity(entity_name) unless authenticate_entity(entity_name)
    when "current"
      authenticate_entity(entity_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("authenticate_") || super
  end

  def authenticate_entity(entity_name)
    if token
      entity_class = entity_name.camelize.constantize
      send(:authenticate_for, entity_class)
    end
  end

  def unauthorized_entity(_entity_name)
    head(:unauthorized)
  end

  def token_from_request_headers
    request.headers["Authorization"]&.split&.last
  end

  def define_current_entity_getter(entity_class, getter_name)
    unless respond_to?(getter_name)
      memoization_var_name = "@_#{getter_name}"
      self.class.send(:define_method, getter_name) do
        unless instance_variable_defined?(memoization_var_name)
          current =
            begin
              KnockKnock::AuthToken.new(token: token).entity_for(entity_class)
            rescue KnockKnock.not_found_exception_class, JWT::DecodeError, JWT::EncodeError
              nil
            end
          instance_variable_set(memoization_var_name, current)
        end
        instance_variable_get(memoization_var_name)
      end
    end
  end
end
