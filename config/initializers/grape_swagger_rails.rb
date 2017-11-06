GrapeSwaggerRails.options.url      = 'api/v1/swagger_doc'
GrapeSwaggerRails.options.app_url  = '/'
GrapeSwaggerRails.options.app_name = 'Partnr'

GrapeSwaggerRails.options.before_filter do |req|
  puts req
end
