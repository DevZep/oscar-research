class ClientsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end


end
