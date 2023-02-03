# GOOGLE AND FACEBOOK OMNIAUTH IN A RAILS APP

Omniauth is a ruby gem that allows you to authenticate users with third party services. In this example we will use Google and Facebook as our third party services.

## Getting Started
To get started we will need to set up an authentication system in our rails app. For this we will use sessions. Sessions are a way to store information about a user in a cookie. This cookie is stored on the users browser and is sent back to the server with every request. This allows us to keep track of the user and their information.
You can check on your browser to see if you have a session cookie by going to the developer tools and looking at the cookies tab. You should see a cookie called <your_app_name>_session. This is the cookie that is used to keep track of the user.
For chrome you can go to the developer tools by pressing F12 and then clicking on the Application tab. Then click on the Cookies tab then you should see your domain click on it and you should see your session cookie.
For firefox you can go to the developer tools by pressing F12 and then clicking on the Storage tab. Then click on the Cookies tab then you should see your domain click on it and you should see your session cookie.
In the images below, you can see that before I log in a user I have no session cookie and after I log in I have a session cookie.

### Setting up the app
Lets start by creating a new rails app. We will call it omniauth-rails.
```
rails new omniauth-rails
```
We will add bcrypt to our gemfile. Bcrypt is a ruby gem that allows us to hash passwords. We will use this to store the users password in the database.
```
gem 'bcrypt'
```
Then we will run bundle install to install the gem.
```
bundle install
```
Now we will create a user model. We will use the rails generator to create the model.
```
rails g model User username email password:digest
```
password:digest will create a password_digest column in the database and add a has_secure_password method to the user model. This will allow us to use the authenticate method to check if a user has the correct password.
```
class User < ApplicationRecord
  has_secure_password
end
```
Now we will run the migration to create the users table in the database.
```
rails db:migrate
```
Now we will create a controller for the users. We will use the rails generator to create the controller.
```
rails g controller Users
```
We will also need to create a controller for the sessions. We will use the rails generator to create the controller.
```
rails g controller Sessions
```

### Application Controller
Now we will add the following methods to the application controller.
```
class ApplicationController < ActionController::Base

    def index
        if !logged_in?
            redirect_to login_path
        end
    end

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def logged_in?
        current_user
    end

end
```

The index method will check if the user is logged in. If the user is not logged in we will redirect them to the login page.
The current_user method will check if the session[:user_id] is set. If it is set we will find the user with that id and set it to the @current_user variable. If the session[:user_id] is not set we will return nil.
The logged_in? method will check if the current_user method returns a user. If it does we will return true. If it does not we will return false.

### Users Controller
Now we will add the following methods to the users controller.
```
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
```
The new method will create a new user object. This will be used in the form to create a new user.
The create method will create a new user and save it to the database. If the user is saved we will set the session[:user_id] to the id of the user. This will allow us to keep track of the user. We will then redirect the user to the root path. If the user is not saved we will render the new template.
The user_params method will allow us to get the parameters from the form and only allow the parameters we want to be passed in.

### Sessions Controller
Now we will add the following methods to the sessions controller.
```
class SessionsController < ApplicationController

    def new
       if logged_in?
              redirect_to root_path
         end
    end

    def create
        @user = User.find_by(username: params[:session][:username])
        if @user && @user.authenticate(params[:session][:password])
            session[:user_id] = @user.id
            redirect_to root_path
        else
            flash[:error] = "Invalid username or password"
            redirect_to login_path
        end

    end

    def destroy
        session.delete :user_id
        redirect_to root_path
    end
  
end
```
The new method will check if the user is logged in. If the user is logged in we will redirect them to the root path.
The create method will find the user by the username. If the user is found and the password is correct we will set the session[:user_id] to the id of the user. This will allow us to keep track of the user. We will then redirect the user to the root path. If the user is not found or the password is incorrect we will redirect the user to the login page.
The destroy method will delete the session[:user_id] and redirect the user to the root path.

### Routes
Now we will add the following routes to the routes.rb file.
```
Rails.application.routes.draw do
  root 'application#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
end
```
The root route will go to the index method in the application controller.
The get '/login', to: 'sessions#new' route will go to the new method in the sessions controller.
The post '/login', to: 'sessions#create' route will go to the create method in the sessions controller.
The delete '/logout', to: 'sessions#destroy' route will go to the destroy method in the sessions controller.
The get '/signup', to: 'users#new' route will go to the new method in the users controller.
The post '/signup', to: 'users#create' route will go to the create method in the users controller.

### Views
Now we will create the views for the users and sessions controllers.
```
mkdir app/views/application
mkdir app/views/users
mkdir app/views/sessions
```

#### Application
Now we will create the index.html.erb file in the application folder and add the following code.
```
<h1> Welcome <%= @current_user.username %>! </h1>
<%= button_to "Logout", logout_path, method: :delete %>
```
This will display the username of the current user and a logout button.

#### Users
Now we will create the new.html.erb file in the users folder and add the following code.
```
<h1> Sign up for a new account </h1>
<%= form_for @user do |f| %>
    <%= f.label :username %>
    <%= f.text_field :username %>
    <%= f.label :email %>
    <%= f.text_field :email %>
    <%= f.label :password %>
    <%= f.password_field :password %>
    <%= f.label :password_confirmation %>
    <%= f.password_field :password_confirmation %>
    <%= f.submit "Sign up" %>
<% end %>

<p>Already have an account? <%= link_to "Login", login_path %></p>
```
This will display a form to create a new user. It will also display a link to the login page.

#### Sessions
Now we will create the new.html.erb file in the sessions folder and add the following code.
```
<h1>Login to your account</h1>
<% if flash[:error] %>
    <p><%= flash[:error] %></p>
<% end %>


<%= form_for :session, url: login_path do |f| %>
    <%= f.label :username %>
    <%= f.text_field :username %>
    <%= f.label :password %>
    <%= f.password_field :password %>
    <%= f.submit "Login" %>
<% end %>

<p>Don't have an account? <%= link_to "Sign up", signup_path %></p>
```
This will display a form to login to an account. It will also display a link to the signup page.

Your application should now be able to create a new user, login to an existing user, and logout of a user.

# GOOGLE OAUTH

















* ...
# omiauth-rails
# omniauth
# omniauth
