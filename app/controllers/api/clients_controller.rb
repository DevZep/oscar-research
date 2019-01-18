module Api
  class ClientsController < ApplicationController

    def index
      clients = list_clients_filter
      render json: { data: clients }, status: '200'
    end

    private
      def filtering_params(params)
        params.slice(:status, :gender)
      end

      def fetch_clients
        org_short_names = Organization.cambodian.visible.pluck(:short_name)
        clients = org_short_names.map do |short_name|
          Organization.switch_to(short_name)
          filtering_params(params).present? ? Client.filter(filtering_params(params)).reload : Client.all.reload
        end
        Organization.switch_to('public')
        clients.flatten
      end

      def clients_ordered(clients)
        clients = clients
        column = params[:order]
        return clients unless column
        if %w(age_as_years id_poor).include?(column)
          ordered = clients.sort_by{ |p| p.send(column).to_i }
        elsif column == 'slug'
          ordered = clients.sort_by{ |p| [p.send(column).split('-').first, p.send(column)[/\d+/].to_i] }
        else
          ordered = clients.sort_by{ |p| p.send(column).to_s.downcase }
        end
        column.present? && params[:descending] == 'true' ? ordered.reverse : ordered
      end

      def list_clients_filter
        clients = clients_ordered(fetch_clients)
      end
  end
end
