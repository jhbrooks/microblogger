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
      command = input.split[0].downcase
      message = input.split[1..-1].join(" ")
      case command
      when "q" then puts "Goodbye!"
      when "t" then tweet(message)
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
      puts "Tweet was not posted (exceeds 140 characters)."
    end
  end
end

blogger = MicroBlogger.new
blogger.run
