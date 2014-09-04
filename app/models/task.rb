class Task < ActiveRecord::Base
  belongs_to :list, class_name: TaskList

  validates :description, presence: ture
  validates :list, presence: true
end
