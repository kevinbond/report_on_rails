class CallsController < ApplicationController 

  #This will be hit on all GETs
  #This is intended for Viewing all of the Reports in the Browser
  def index
    @cdrs = Call.all
  end
  
  def destroy
    @record = Call.find(params[:id])
    @record.destroy
    redirect_to "http://mighty-crag-3312.herokuapp.com/calls", :notice => "This CDR record has been deleted successfully!"
  end

  #This is the start of the app
  def create
    v = Tropo::Generator.parse request.env["rack.input"].read
    t = Tropo::Generator.new

    #This will be hit when a request is sent to Tropo to make a call
    if v[:session][:parameters]

      to = v[:session][:parameters][:num]
      #Create record
      @c = Call.create(:start_time => Time.now.utc.strftime('%a %b %d %H:%M:%S +0000 %Y'), :to => to, :from => "14071234321", :success => "true", :duration => Time.now.utc.seconds_since_midnight.to_i, :network => "VOICE", :direction => "out")
      #make the call
      t.call(:to => "+#{to}")
      #send thread to make the call
      t.on :event => 'continue', :next => 'calls/sendCall'
      
    #This is hit when a user calls into the app
    else
      
      #Create record
      @c = Call.create(:start_time => Time.now.utc.strftime('%a %b %d %H:%M:%S +0000 %Y'), :to => v[:session][:to][:name], :from => v[:session][:from][:name], :success => "true", :duration => Time.now.utc.seconds_since_midnight.to_i, :network => v[:session][:to][:channel], :direction => "in")
     
      #send the thread to start the functionalities 
      t.on :event => 'continue', :next => "calls/startCall"
      t.on :event => 'hangup', :next => 'calls/hangup'
    end

    #send JSON back to Tropo
    render :json => t.response
  end

  #This method makes a call
  def sendCall
    
    begin
      
      t = Tropo::Generator.new
      
      #start necessary functionalities 
      t.say("Just wanted to give you a call to see how you have been!")
      t.say("Alrighty then, thanks for the update, Goodbye!")

      #send thread accordingly 
      t.on :event => 'continue', :next =>"cleanupApp"
      t.on :event => 'hangup', :next => 'hangup'
      t.on :event => 'incomplete', :next => 'error'

      #send JSON back to Tropo
      render :json => t.response

    #update record if an error occured 
    rescue Exception => e
      @c =Call.find(Call.all[Call.all.length - 1].id)
      @c.success = "*** Encountered App Error - #{e.message}***"
      @c.save
    end  
    
  end

  #This is the start of an incoming call app
  def startCall

    begin

      t = Tropo::Generator.new
      
      #apps functionalities
      t.say("Welcome to the reporting demo!")
      t.ask :name => 'start', 
      :timeout => 60, 
      :say => {:value => "Is this your first time here?"},
      :choices => {:value => "yes, no"}

      #send thread accordingly 
      t.on :event => 'continue', :next => "answerQ"
      t.on :event => 'hangup', :next => 'hangup'
      
      #send JSON back to Tropo
      render :json => t.response
    
    #update record if an error occured
    rescue Exception => e
      @c =Call.find(Call.all[Call.all.length - 1].id)
      @c.duration = Time.now - @c.start_time
      @c.success = "*** Encountered App Error - #{e.message}***"
      @c.save
    end
    
  end
  
  #This method is the response the the question in the start method
  def answerQ
    
    begin
      
      v = Tropo::Generator.parse request.env["rack.input"].read
      t = Tropo::Generator.new
      
      #extract answer from the result object
      answer = v[:result][:actions][:start][:value]
      
      #read answer and react accordingly with variable functionalities
      if answer == 'yes'
        t.say("Well, thanks for joining with us. It's good to see a new face around here")
      elsif answer == 'no'
        t.say("Welcome back! We've been wondering when you were going to come back.")
      end
      
      t.say("Alrighty then, thanks for stopping by, Goodbye!")
      
      #send thread according
      t.on :event => 'continue', :next =>"cleanupApp"
      t.on :event => 'hangup', :next => 'hangup'

      #send JSON back to Tropo
      render :json => t.response
    
    #update record if an error occured 
    rescue Exception => e
      @c =Call.find(Call.all[Call.all.length - 1].id)
      @c.duration = Time.now - @c.start_time
      @c.success = "*** Encountered App Error - #{e.message}***"
      @c.save
    end    
    
  end
  
  #This method will be hit if an SMS is sent to Tropo
  def sms
    
    v = Tropo::Generator.parse request.env["rack.input"].read
    t = Tropo::Generator.new

    #create an inbound record
    Call.create(:start_time => Time.now.utc.strftime('%a %b %d %H:%M:%S +0000 %Y'), :to => v[:session][:to][:id], :from => v[:session][:from][:id], :success => "true", :duration => 0, :network => v[:session][:to][:channel], :direction => "in")
    #reply to SMS
    initialText = v[:session][:initial_text]
    t.say("Thanks for the text, you said #{initialText}")
    #create an outbound reply record
    Call.create(:start_time => Time.now.utc.strftime('%a %b %d %H:%M:%S +0000 %Y'), :to => v[:session][:from][:id], :from => v[:session][:to][:id], :success => "true", :duration => 0, :network => v[:session][:to][:channel], :direction => "out")

    #send JSON back to Tropo
    render :json => t.response

  end
  
  def hangup
    
    #update record
    @c =Call.find(Call.all[Call.all.length - 1].id)
    @c.success = "answered/hungup"
    @c.duration = Time.now.utc.seconds_since_midnight.to_i - @c.duration
    @c.save
    
  end
  
  def cleanupApp
    
    t = Tropo::Generator.new
    v = Tropo::Generator.parse request.env["rack.input"].read
    
    
    #hangup call
    t.hangup
    
    #send JSON back to Tropo
    render :json => t.response
    @c =Call.find(Call.all[Call.all.length - 1].id)
    
    #update record
    @c =Call.find(Call.all[Call.all.length - 1].id)
    @c.duration = Time.now.utc.seconds_since_midnight.to_i - @c.duration
    @c.duration * (-1) if @c.duration < 0
    @c.save
    puts "\n\n\n**************** #{@c.duration}"
    
    
  end
  
  def error
    
    #update record
    @c =Call.find(Call.all[Call.all.length - 1].id)
    @c.success = "Outbound Call Issue"
    @c.save
    
  end

end