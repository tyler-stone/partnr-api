class Base < Grape::API
  content_type :json, 'application/json'

  default_format :json

  helpers do
    include V1::Helpers::ValidationHelper
    include V1::Helpers::ParamHelper
  end

  mount V1::Mounter => '/v1'
end
