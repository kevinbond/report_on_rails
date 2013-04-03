#Description
***
This is a Ruby on Rails Tropo app which tracks the call progress and returns the following data to a database:
*Time of the call
*To number
*From number
*Network
*Call success
*Duration of the call
*Direction(in/out)

#How to create your app in the terminal
***
The first thing you will need to do is create the Rails app. You can use the following command in the terminal:
    
    rails new tropo_on_rails

This will create a Rails application called tropo_on_rails in a directory called tropo_on_rails. The next thing you will need to do is create the controller that will handle all of your Tropo methods. To so this, run the following command in the terminal(make sure you cd into the Rails folder before running this command):
    
    rails generate controller tropo
    
This creates 6 files, however, we will only be concerned with tropo_controller.rb which is where we will add all of the Tropo functionalities.

#Gems
***
You will need to go into your Gemfile and add the following line:
    
    gem 'tropo-webapi-ruby'

You will also need to change sqlite3 to pg. This change is for Heroku's sake, not Rails. If you are just going to run it indepently on your server, you can leave that alone. But do not change this until you are ready to deploy to Heroku as testing in your own environment will fail. 

#When Building your Rails app
***
When you start to build your app, there are a few things to note. All of the Tropo functionalities will be executed in the Controller. Because Tropo only needs the JSON that is produced, sending the thread to the corresponding View will prodcue an error in Tropo since Views produce HTML. To avoid this, you can send the JSON back to Tropo directly by runing the following:

    render :json => t.response

The render :json is what will send the JSON back to Tropo and will skip the View completely

Another important factor you will need to implement is the routing system for your app. If you controller is called "Tropo", for example, all of your controllers will be methods with in that class. To call these methods, you will need to update your routes.rb file in the config folder. So if you want to call the sendSMS method in that controller, you will need to add the following in the routes.rb file:

    post 'tropo/sendSMS' => 'tropo#sendSMS'

This will hit the necessary Controller file (tropo) and send the thread to the method that is called (sendSMS).

Within you Tropo app, you can just send the thread to a new method in the controll by using the on event. So if I have a questions that I want to ask the user, I can send the Tropo thread to tropo/question. Once that method asked the question, you will use the on event(which is a Tropo method) to send the thread to tropo/answer as follows:

    t.on :event => 'continue', :next =>"answer"

As you can see, you do not have to include the Controller name, just the route. However, you will need to specify the entire route in your routes.rb class as shown below:

    post 'tropo/answer' => 'tropo#answer'
    
Then rails does the rest for you.

#Building you database
***
The nice part about using Rails to build your Tropo application is the database that comes with it. You can run the following line in the termial to create your database with specific parameters as shown below:
    
    rails generate scaffold Call direction:string duration:integer from:string network:string start_time:string success:string to:string

This will create a model which will look for those parameters when entering stuff into the data base. You can view my call.rb Model to see some clean up that I run on the data.

The final step is to migrate the DB. You can run the following code to do this:
    
    rake db:migrate
    
That will create everything that you need. You can test this out in your terminal through your rails console. Run the following commands in your terminal to create your first report:
    
    rails c
    
    @report = Call.create(:direction => "in", :duration => 25, :from => "14075551000", :to => "14075552000", :network => "TEXT", :start_time => "thursday 1pm", :success => "true")
    
    @report

This will create a new record and saves it to the DB automatically because of .create. You can use .new, however, you will need to run @report.save to save it to the DB.

