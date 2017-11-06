module Validators
  class ValidPerPage < Grape::Validations::Base
    def validate_param!(attr_name, params)
      params[attr_name] = clamp(params[attr_name], @option.min, @option.max)
    end

    def clamp(value, min, max)
      [[value, max].min, min].max
    end
  end
end
