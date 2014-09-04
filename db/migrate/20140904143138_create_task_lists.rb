class CreateTaskLists < ActiveRecord::Migration
  def change
    create_table :task_lists do |t|
      t.belongs_to :owner, index: true

      t.timestamps
    end
  end
end
