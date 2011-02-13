class UsersController < ApplicationController

  #devise authentication
  #before_filter :authenticate_user!
  before_filter :get_user, :only => [:index,:new,:edit]
  before_filter :accessible_roles, :only => [:new, :edit, :show, :update, :create]
  # CanCan provides a convenient load_and_authorize_resource method in the controller, but what exactly is this doing? 
  	# It sets up a before filter for every action to handle the loading and authorization of the controller. 
  	# Let's say we have a typical RESTful controller with that line at the top.
  load_and_authorize_resource # :only => [:show,:new,:destroy,:edit,:update]
	#skip_authorize_resource :only => :new

  private

  # Get roles accessible by the current user
  #----------------------------------------------------
  def accessible_roles
    @accessible_roles = Role.accessible_by(current_ability,:read)
  end

  # Make the current user object available to views
  #----------------------------------------
  def get_user
    @current_user = current_user
  end

  public

  # GET /users
  # GET /users.xml
  # GET /users.json
  def index
    #@users = User.accessible_by(current_ability, :index).limit(20)
  	# A collection of resources is automatically loaded in the index action using accessible_by
  	 # @users automatically set to User.accessible_by(current_ability)
    # @users = @users.paginate :page => params[:page],  :per_page => 2, :order => 'updated_at DESC'
	page = params[:page] 
  	q = params[:q]
  	column = params[:column]
#  	@users = @users.paginate :per_page =>2, :page => page,
#            :conditions => ['email like ? or roles.find_by_name( ?) ', "%#{q}%", "#{q}"], :order => 'email'
  if ! column.nil? and column.downcase == 'role'
     	@users = @users.paginate  :per_page =>2, :page => page, :include => :roles,
               :conditions => ['roles.name like ? ', "%#{q}%"], :order => 'email'
  else
  	  # search email column 
     	@users = @users.paginate  :per_page =>2, :page => page, :include => :roles,
               :conditions => ['email like ? ', "%#{q}%"], :order => 'email'
   end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.json { render :json => @users}
    end
  end

  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.json
  def show
    #@user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.json  { render :json => @user }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  # GET /users/new
  # GET /users/new.xml
  # GET /users/new.json
  def new
    #@user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
      format.json  { render :json => @user }
    end
  end

  # GET /users/1/edit
  # GET /users/1/edit.xml
  # GET /users/1/edit.json
  def edit
    #@user = User.find(params[:id])

    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  # POST /users
  # POST /users.xml
  # POST /users.json
  def create
   # @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
        format.json { render :json => @user.to_json, :status => 200 }
      else
        format.html { render :action => "new", :status => :unprocessable_entity }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.json { render :text => "Could not create user", :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    #@user = User.find(params[:id])
    if params[:user][:password].blank?
      [:password, :password_confirmation, :current_password].collect { |p| params[:user].delete(p) }
    else
       @user.errors[:base] << "The password you entered is incorrect" unless @user.valid_password?(params[:user][:current_password])
    end
    respond_to do |format|
      if @user.errors[:base].empty?  and  @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => @user.to_json, :status => 200 }
      else
        format.html { render :action => "edit", :status => :unprocessable_entity }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.json { render :text => "Could not update user", :status => :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  # DELETE /users/1.json
  def destroy
    #@user = User.find(params[:id])
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
      format.json { respond_to_destroy(:ajax)}
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end
end
