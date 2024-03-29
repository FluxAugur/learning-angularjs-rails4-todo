require 'rails_helper'

RSpec.describe HomeController, :type => :controller do
  let(:user) { create(:user) }

  describe "GET index" do
    it "should render when user is not signed in" do
      get :index
      response.should be_ok
      response.should render_template('index')
    end

    it "should redirect to the user's task list if signed in" do
      sign_in(user)
      get :index
      response.should redirect_to(task_list_path(id: user.task_list))
    end
  end
end
