require 'rails_helper'

describe TaskListsController do
  context "for a logged-in user with a task list" do
    let(:task_list) { create(:task_list) }
    let(:user) { task_list.owner }
    before { sign_in(user) }

    describe "GET show" do
      it "should return 200 for the task list" do
        get :show, id: task_list.id
        response.should be_ok
      end

      it "should raise RecordNotFound when task list doesn't exist" do
        expect {
          get :show, id: 1
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should return 404 when task list doesn't exist" do
        expect {
          get :show, id: 1
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end