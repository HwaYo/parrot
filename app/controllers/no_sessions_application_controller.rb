class NoSessionsApplicationController < ApplicationController
  skip_before_action :login?
end
