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