class ErrorsController < ApplicationController
  layout false

  def show
    raise ActionController::RoutingError.new(params[:path])
  end
end
