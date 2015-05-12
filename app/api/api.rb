require 'doorkeeper/grape/helpers'

class API < Grape::API
  helpers Doorkeeper::Grape::Helpers

  prefix 'api'
  version 'v1', using: :path

  before do
    doorkeeper_authorize!
  end
end