module Dimitrij::Events::Ready
  extend Discordrb::EventContainer

  ready do |event|
    event.bot.game = 'Table tennis'
  end
end
