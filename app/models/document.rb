class Document < ActiveRecord::Base
  attr_accessible :title, :class_id, :date, :link
end
