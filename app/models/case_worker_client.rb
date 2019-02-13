class CaseWorkerClient < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
end
