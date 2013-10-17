class Admin::UsersController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_filter :verify_admin

  def index
    @users = User.order("created_at ASC")
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
	#possible vulnerability with attr_accessable on the 'admin' attribute
    @user.save

    redirect_to action: 'index', :flash => { :notice => "User added!" }
    return
  end
end
