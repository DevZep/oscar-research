class ProgramStreamService < ActiveRecord::Base
  belongs_to :program_stream
  belongs_to :service
end
