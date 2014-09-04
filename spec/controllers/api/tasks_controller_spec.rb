require 'rails_helper'

describe Api::TasksController do
  context "for a logged-in user with two tasks" do
    let(:task_list) { create(:task_list, :with_tasks) }
    let(:task1) { task_list.tasks[0] }
    let(:task2) { task_list.tasks[1] }
    let(:user) { task_list.owner }

    before { sign_in(user) }

    describe "GET index" do
      it "should return json of those tasks" do
        get :index, task_list_id: task_list.id
        tasks = JSON.parse(response.body)
        tasks.should == [
          {'id' => task1.id, 'description' => task1.description,
            'priority' => nil, 'due_date' => nil, 'completed' => false},
          {'id' => task2.id, 'description' => task2.description,
            'priority' => nil, 'due_date' => nil, 'completed' => false}
        ]
      end
    end

    describe "GET create" do
      let(:post_create) do
        post :create, task_list_id: task_list.id, task: {description: "New task"}
      end

      it "should add the record to the database" do
        expect {
          post_create
        }.to change(Task, :count).by(1)
      end

      it "should return 200 OK" do
        post_create
        response.should be_success
      end

      it "should preserve passed parameters" do
        post_create
        Task.order(:id).last.description.should == "New task"
      end

      it "should raise ParameterMissing exception when task param is missing" do
        expect {
          post :create, task_list_id: task_list.id
        }.to raise_error(ActionController::ParameterMissing)
      end

      it "should ignore unknown parameters" do
        post :create, task_list_id: task_list.id,
          task: {description: "New task", foobar: 1324}
        response.should be_ok
      end
    end

    describe "GET update" do
      let(:patch_update) do
        patch :update, task_list_id: task_list.id, id: task1.id,
          task: {description: "New description", priority: 1, completed: true}
      end

      it "should update passed parameters of the given task" do
        patch_update
        task1.reload.description.should == "New description"
        task1.priority.should == 1
        task1.completed.should be_true
      end

      it "should return 200 OK" do
        patch_update
        response.should be_success
      end
    end

    describe "GET destroy" do
      let(:delete_destroy) do
        delete :destroy, task_list_id: task_list, id: task1.id
      end

      it "should remove the task from the database" do
        delete_destroy
        expect { task1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should return 200 OK" do
        delete_destroy
        response.should be_success
      end
    end
  end
end
