# GOOGLE OMNIAUTH IN A RAILS APP

Omniauth is a ruby gem that allows you to authenticate users with third party services. In this example we will use Google as our third party service. We will use the omniauth-google-oauth2 gem to authenticate users with Google.

## Getting Started
To get started we will need to set up an authentication system in our rails app. For this we will use sessions. Sessions are a way to store information about a user in a cookie. This cookie is stored on the users browser and is sent back to the server with every request. This allows us to keep track of the user and their information.
You can check on your browser to see if you have a session cookie by going to the developer tools and looking at the cookies tab. You should see a cookie called <your_app_name>_session. This is the cookie that is used to keep track of the user.
For chrome you can go to the developer tools by pressing F12 and then clicking on the Application tab. Then click on the Cookies tab then you should see your domain click on it and you should see your session cookie.
For firefox you can go to the developer tools by pressing F12 and then clicking on the Storage tab. Then click on the Cookies tab then you should see your domain click on it and you should see your session cookie.

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
First we will need to create a new project in the google developer console.
Go to [https://console.developers.google.com/](https://console.developers.google.com/) and under select a project click on new project.
Give your project a name and click create. eg. omniauth-rails
While on the project under APIs & Services click on OAuth consent screen.
Set the user type to external and click create.
On the next page fill out the information and click save.
The app name, user support email, and developer contact information are required.
If your application is in production you will need to add your application url to the authorized domains.You can also upload your app logo, a privacy policy url, and a terms of service url.
Click on save and continue.
On the scopes page, at the moment we don't need to add any scopes. Click on save and continue.
Scopes are used to limit the amount of information that is shared with the application. For example, if you only want the user's email address you can add the scope https://www.googleapis.com/auth/userinfo.email. If you want the user's email address and their profile picture you can add the scope https://www.googleapis.com/auth/userinfo.profile.
Click on save and continue.
On the test users page you can add test users to your application.This means that only the email addresses that you add will be able to login to your application.I will not be adding any test users.
Click on save and continue.
On the summary page you can see all of the information that you have entered. Click on back to dashboard.
On the side dashboard click on credentials and then click on create credentials.
Select OAuth client ID and under application type select web application.
Give your application a name and add http://localhost:3000/auth/google_oauth2/callback to the authorized redirect URIs.
Click on create.
You will now see your client ID and client secret.
Save this as we will need them later.

### Back to our Rails application
Now we will add the following to the Gemfile.
```
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'dotenv-rails'
gem 'omniauth-rails_csrf_protection'
```
gem 'omniauth' is the main gem that we will be using.
gem 'omniauth-google-oauth2' is the gem that will allow us to use google oauth.
gem 'dotenv-rails' is the gem that will allow us to store our client ID and client secret in a .env file.
gem 'omniauth-rails_csrf_protection' is the gem that will protect against CSRF attacks.


Then run bundle install.
```
bundle install
```
Now we will create a .env file in the root directory of our application.
```
touch .env
```
Now we will add the following to the .env file.
```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```
Remember to add your .env file to your .gitignore file.
Syntax: Note that there are no quotes around the client ID and client secret and no spaces around the equal sign.

Now we will create a new initializer file in the config/initializers directory.
```
touch config/initializers/omniauth.rb
```
Now we will add the following to the omniauth.rb file.
```
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
end
```
This is a middleware that will allow us to use omniauth with our application.
The provider method will allow us to use google oauth.
You can also use other providers such as facebook, twitter, github, etc.
You can configure several options, which you pass in to the provider method via a hash:
```
provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
    {
        scope: 'email, profile', -- This will allow us to get the user's email address and profile picture.
        prompt: 'select_account', -- This will allow the user to select which account they want to login with.
        image_aspect_ratio: 'square', -- This will make sure that the profile picture is a square.
        image_size: 50, -- This will make sure that the profile picture is 50x50 pixels.
    }
```
To read more about gem 'omniauth-google-oauth2' go to [https://github.com/zquestz/omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2).

Remember to restart your server after making any changes to the omniauth.rb file.

Create a migration to add a uid and provider column to the users table.
```
rails g migration AddUidAndProviderToUsers uid provider
```
Then run the migration.
```
rails db:migrate
```


Let's add a new omniauth action to the sessions controller.
```
def omniauth
        @user = User.find_or_create_by(uid: request.env['omniauth.auth']['uid'], provider: request.env['omniauth.auth']['provider']) do |u|
            u.username = request.env['omniauth.auth']['info']['name']
            u.email = request.env['omniauth.auth']['info']['email']
            u.password = SecureRandom.hex(10)
        end
        if @user.valid?
            session[:user_id] = @user.id
            redirect_to root_path
        else
            render :new
        end
end
```
The auth hash is a hash that contains all of the information that we get from the provider.
```
{
  "provider" => "google_oauth2",
  "uid" => "100000000000000000000",
  "info" => {
    "name" => "John Smith",
    "email" => "john@example.com",
    "first_name" => "John",
    "last_name" => "Smith",
    "image" => "https://lh4.googleusercontent.com/photo.jpg",
    "urls" => {
      "google" => "https://plus.google.com/+JohnSmith"
    }
  },
  ...
}
```
You can read more about the auth hash at [https://github.com/zquestz/omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2).
We can access the information by using the hash syntax.
For example, if we want to get the user's email address we can use request.env['omniauth.auth']['info']['email'].
In the omniauth action in the sessions controller we are using the find_or_create_by method to find the user by their uid and provider or create a new user if they don't exist.
We are also using the SecureRandom.hex(10) to set the password.This sets the password to a random string of 10 characters.

Now we will add a new route to the routes.rb file.
```
get '/auth/:provider/callback', to: 'sessions#omniauth'
```
This route will allow us to use the omniauth action in the sessions controller.
We use ':provider' to make the route dynamic.This means that we can use this route for any provider. eg facebook, twitter, github, etc.

Now we will add a new button to the login page.
In the app/views/sessions/new.html.erb file add the following.
```
<h3> Or login with Google</h3>
<%= button_to "Login with Google", "/auth/google_oauth2" %>
```
This will create a button that will allow the user to login with google.
A button_to is a form that will send a post request to the specified path.

Our application is now ready to use google oauth.
To test it out, run the rails server and go to [http://localhost:3000/login](http://localhost:3000/login).

Check out the [live site](https://railsomniauth.onrender.com) here.

That's it for this tutorial.Thank you for reading.
Remember to check out the source code on github at [https://github.com/Annastacia-dev/omniauth-rails](https://github.com/Annastacia-dev/omniauth-rails).
Feel free to leave any comments or questions below or reach out to me on email at [annetotoh@gmail.com](mailto:annetotoh@gmail.com).

