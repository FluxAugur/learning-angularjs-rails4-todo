require 'rails_helper'

RSpec.describe User, :type => :model do
  context "for new valid user" do
    let(:user) { create(:user) }

    it "should have a corresponding task list" do
      user.task_list.should be_a(TaskList)
    end
  end
end
