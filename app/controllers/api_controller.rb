class ApiController < ApplicationController
  rate_limit to: 5, within: 1.second

  private

  def handle_rate_limit
    render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
  end
end 