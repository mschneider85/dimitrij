module Dimitrij::Commands
  Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each { |file| require file }

  @commands = [
    Lang,
    Tt,
    Flip,
    Roll
  ]

  def self.include!
    @commands.each do |command|
      Dimitrij::BOT.include!(command)
    end
  end
end
