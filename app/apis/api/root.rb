require 'grape'
module API
  class Root < Grape::API
    prefix 'api'
    # version 'v1'
    format :json
    mount API::Ver1::Poker
  end
end
