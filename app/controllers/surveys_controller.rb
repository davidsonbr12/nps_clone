class SurveysController < ApplicationController
  # This ensures a user must be signed in AND have the 'admin' role to access any action here
  before_action :authenticate_user!
  before_action :authenticate_admin!
end
