module Validators
  class Length < Grape::Validations::Base
    def validate_param!(attr_name, params)
      if params[attr_name].nil?
        return
      else
        unless params[attr_name].length <= @option
          fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "can be no more than #{@option} characters"
        end
      end
    end
  end
end
