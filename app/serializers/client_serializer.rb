class ClientSerializer < ActiveModel::Serializer
  attributes :id, :age, :gender, :status, :district, :current_province


  def age
    object.age_as_years
  end

  def current_province
    object.province_name
  end

  def district
    object.district_name
  end
end
