#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require "jumpstart_auth"

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Intitializing..."
    @client = JumpstartAuth.twitter
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
test_string = "".ljust(141, "test ")
blogger.tweet(test_string)
