module Validators
  class ValidUser < Grape::Validations::Base
    def validate_param!(attr_name, params)
      !(User.find_by(id: params[attr_name]).nil?)
    end
  end
end
