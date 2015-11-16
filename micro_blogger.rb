#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require "jumpstart_auth"

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Intitializing..."
    @client = JumpstartAuth.twitter
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    until command == "q"
      printf "Enter command: "
      input = gets.chomp!
      parts = input.split
      command = parts[0].downcase
      case command
      when "q" then puts "Goodbye!"
      when "t" then tweet(parts[1..-1].join(" "))
      when "dm" then dm(parts[1], parts[2..-1].join(" "))
      when "spam" then spam_my_followers(parts[1..-1].join(" "))
      when "elt" then everyones_last_tweet
      else
        puts "Sorry, I don't know how to #{command}."
      end
    end
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
      puts "Tweet posted.\n#{message}"
    else
      puts "Tweet not posted (exceeds 140 characters)."
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    if followers_list.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Message not sent (target is not a follower)."
    end
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    sorted_friends = friends.sort_by do |friend|
      @client.user(friend).screen_name.downcase
    end
    sorted_friends.each do |friend|
      name = @client.user(friend).screen_name
      last_message = @client.user(friend).status.text
      timestamp = @client.user(friend).status.created_at
      formatted_time = timestamp.strftime("%A, %b %d")
      puts "On #{formatted_time}, #{name} said..."
      puts last_message
      puts
    end
  end

  private

  def followers_list
    @client.followers.map do |follower|
      @client.user(follower).screen_name
    end
  end
end

blogger = MicroBlogger.new
blogger.run
