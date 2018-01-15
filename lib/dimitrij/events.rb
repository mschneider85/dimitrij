module Dimitrij::Events
  Dir["#{File.dirname(__FILE__)}/events/*.rb"].each { |file| require file }

  @events = [
    Heartbeat,
    Ready
  ]

  def self.include!
    @events.each do |event|
      Dimitrij::BOT.include!(event)
    end
  end
end
