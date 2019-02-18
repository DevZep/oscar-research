module Api
  class AssessmentDomainsController < Api::ApplicationController
    def index
      client_id = params[:client_id]
      data = Province.find(params[:province_id]).districts
      render json: { data: data }
    end
  end
end
