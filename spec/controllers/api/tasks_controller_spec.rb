require 'rails_helper'

describe Api::TasksController do
  context "for a logged-in user with two tasks" do
    let(:task_list) { create(:task_list, :with_tasks) }
    let(:task1) { task_list.tasks[0] }
    let(:task2) { task_list.tasks[1] }
    let(:user) { task_list.owner }

    before { sign_in(user) }

    describe "#index" do
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

      it "should raise RecordNotFound when trying to get tasks for non-existent list" do
        expect {
          get :index, task_list_id: 0
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#create" do
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

      it "should return json of the just created record" do
        post_create
        json_response["id"].should == be_an(Integer)
        json_response["completed"].should == false
        json_response["description"].should == "New task"
        json_response["due_date"].should == nil
        json_response["priority"].should == nil
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
          task: {description: "New task", foobar: 1234}
        response.should be_ok
      end

      it "should raise a validation error when description is too long" do
        expect {
          post :create, task_list_id: task_list.id, task: {description: "a"*300}
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "#update" do
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

      it "should raise RecordNotFound when trying to update non-existent task" do
        expect {
          patch :update, task_list_id: task_list.id, id: 0,
            task: {description: "New description", priority: 1, completed: true}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#destroy" do
      let(:delete_destroy) do
        delete :destroy, task_list_id: task_list, id: task1.id
      end

      it "should remove the task from database" do
        delete_destroy
        expect { task1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should return 200 OK" do
        delete_destroy
        response.should be_success
      end

      it "should raise RecordNotFound when trying to destroy non-existent task" do
        expect {
          delete :destroy, task_list_id: task_list, id: 0
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
