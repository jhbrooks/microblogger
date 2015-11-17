#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require "jumpstart_auth"
require "bitly"

# This class operates a command line Twitter client
class MicroBlogger
  attr_reader :client

  def initialize
    puts "Intitializing..."
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    @bitly = Bitly.new("hungryacademy", "R_430e9f62250186d2612cca76eee2dbc6")
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    until command == "q"
      print "Enter command: "
      input = gets.chomp!
      parts = input.split
      command = parts[0].downcase
      remainder = parts[1..-1]
      handle_command(command, remainder)
    end
  end

  private

  def handle_command(command, remainder)
    case command
    when "q" then puts "Goodbye!"
    when "t" then tweet(remainder.join(" "))
    when "st" then tweet(shorten_urls(remainder).join(" "))
    when "dm" then dm(remainder[0], remainder[1..-1].join(" "))
    when "sdm" then dm(remainder[0], shorten_urls(remainder[1..-1]).join(" "))
    when "spam" then spam_my_followers(remainder.join(" "))
    when "sspam" then spam_my_followers(shorten_urls(remainder).join(" "))
    when "elt" then everyones_last_tweet
    when "s" then shorten(remainder.join(" "))
    else
      puts "Sorry, I don't know how to #{command}."
    end
  end

  def shorten_urls(potential_urls)
    potential_urls.map do |potential_url|
      if potential_url.match(%r{http:\/\/\S+\.com})
        url = potential_url.scan(%r{http:\/\/\S+\.com}).first
        potential_url.sub(%r{http:\/\/\S+\.com}, shorten(url))
      else
        potential_url
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

  def shorten(original_url)
    begin
      shortened_url = @bitly.shorten(original_url).short_url
      puts "Shortening #{original_url}..."
      puts "...shortened to #{shortened_url}"
      shortened_url
    rescue BitlyError
      puts "Shortening #{original_url}..."
      puts "...shortening failed (invalid URL for Bitly)."
      original_url
    end
  end

  def followers_list
    @client.followers.map do |follower|
      @client.user(follower).screen_name
    end
  end
end

blogger = MicroBlogger.new
blogger.run
