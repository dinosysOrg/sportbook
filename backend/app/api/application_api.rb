class ApplicationApi < Grape::API
  prefix 'api'
  mount V1::Api
end
