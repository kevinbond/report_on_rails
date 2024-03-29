#Description
***
This is a Ruby on Rails Tropo app which tracks the call progress and returns the following data to a database:

- Time of the call
- To number
- From number
- Network
- Call success
- Duration of the call
- Direction(in/out)

#How to create your app in the terminal
***
The first thing you will need to do is create the Rails app. You can use the following command in the terminal:    
<pre><code>rails new tropo_on_rails</code></pre>

This will create a Rails application called tropo_on_rails in a directory called tropo_on_rails. The next thing you will need to do is create the controller that will handle all of your Tropo methods. To so this, run the following command in the terminal(make sure you cd into the Rails folder before running this command):
<pre><code>rails generate controller tropo</code></pre>
    
This creates 6 files, however, we will only be concerned with tropo_controller.rb which is where we will add all of the Tropo functionalities.

#Gems
***
You will need to go into your Gemfile and add the following line:
    
<pre><code>gem 'tropo-webapi-ruby'</code></pre>

You will also need to change sqlite3 to pg. This change is for Heroku's sake, not Rails. If you are just going to run it indepently on your server, you can leave that alone. But do not change this until you are ready to deploy to Heroku as testing in your own environment will fail. 

#When Building your Rails app
***
When you start to build your app, there are a few things to note. All of the Tropo functionalities will be executed in the Controller. Because Tropo only needs the JSON that is produced, sending the thread to the corresponding View will prodcue an error in Tropo since Views produce HTML. To avoid this, you can send the JSON back to Tropo directly by runing the following:

<pre><code>render :json => t.response</code></pre>

The render :json is what will send the JSON back to Tropo and will skip the View completely

Another important factor you will need to implement is the routing system for your app. If your controller is called "Tropo", for example, all of your controllers will be methods within that class. To call these methods, you will need to update your routes.rb file in the config folder. So if you want to call the sendSMS method in that controller, you will need to add the following in the routes.rb file:

<pre><code>post 'tropo/sendSMS' => 'tropo#sendSMS'</code></pre>

This will hit the necessary Controller file (tropo) and send the thread to the method that is called (sendSMS).

Within your Tropo app, you can just send the thread to a new method in the controll by using the on event. So if I have a questions that I want to ask the user, I can send the Tropo thread to tropo/question. Once that method asked the question, you will use the on event(which is a Tropo method) to send the thread to tropo/answer as follows:

<pre><code>t.on :event => 'continue', :next =>"answer"</code></pre>

As you can see, you do not have to include the Controller name, just the route in the on event. However, you will need to specify the entire route in your routes.rb class as shown below:

<pre><code>post 'tropo/answer' => 'tropo#answer'</code></pre>
    
Then rails does the rest for you.

#Building you database
***
The nice part about using Rails to build your Tropo application is the database that comes with it. You can run the following line in the termial to create your database with specific parameters as shown below:
    
<pre><code>rails generate scaffold Call direction:string duration:integer from:string network:string start_time:string success:string to:string</code></pre>

This will create a model which will look for those parameters when entering stuff into the data base. You can view my call.rb Model to see some clean up that I run on the data.

The final step is to migrate the DB. You can run the following code to do this:
    
<pre><code>rake db:migrate</code></pre>
    
That will create everything that you need. You can test this out in your terminal through your rails console. Run the following commands in your terminal to create your first report:
    
<pre><code>rails c</code></pre>
<pre><code>@report = Call.create(:direction => "in", :duration => 25, :from => "14075551000", :to => "14075552000", :network => "TEXT", :start_time => "thursday 1pm", :success => "true")    </code></pre>
<pre><code>@report</code></pre>

This will create a new record and saves it to the DB automatically because of .create. You can use .new, however, you will need to run @report.save to save it to the DB.

Now to view this, you will need to create an index.html.erb file in views in the calls directory(or whatever you named your controller). You can simply copy and paste what I created. Then if you run the following in the termianl:

<pre><code>rails server</pre></code>

You will be able to enter in the URL that is produced with the route set to calls(or whatever you named your controller) and the GET called by the browser will print the DB contents to the browser. You will go to the following URL to view it:

<pre><code>http://0.0.0.0:3000/calls</pre></code>

You will be able to see a delete link that will destroy a record if clicked.

To note, you will need to create the GET route. To do this, go to routes.rb and enter the following in:

<pre><code>resources :calls</pre></code>

#Heroku setup
***
Once you app is completely setup and working, it is relatively simple to launch it to Heroku. You will need to setup an account there by going to https://id.heroku.com/signup

This is where you will need to change the sqlite3 gem to pg. Access your gem file, change the gem and then run the following in the terminal:
<pre><code>bundle install</pre></code>

Once you have created your account and reinstalled the bundles, run the following commands in the terminal:
<pre><code>heroku login</pre></code>
<pre><code>git init</pre></code>
<pre><code>git add .</pre></code>
<pre><code>git commit -m "init"</pre></code>
<pre><code>heroku create</pre></code>
<pre><code>git push heroku master</pre></code>
    
If you run into an error running the last command, then you will need to add your public key to Heroku. You can do that by running the following command:

<pre><code>heroku keys:add ~/.ssh/id_rsa.pub</pre></code>

We need to ensure we have one dyno running the web process type which can be done with the following command:

<pre><code>heroku ps:scale web=1</pre></code>

Finally, you can see if your app is running on Heroku successfully by running this final command:

<pre><code>heroku open</pre></code>

If all is well, then you can use that link that heroku open gave to you with the beginning routes appened to it as the URL that powers your Tropo app in Tropo. Now you are running Tropo using Ruby on Rails! Congrats!