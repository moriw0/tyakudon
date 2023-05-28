class LineStatus < ApplicationRecord
  belongs_to :record
  enum line_type: { inside_the_store: 1, outside_the_store: 2, other: 3 }
end
