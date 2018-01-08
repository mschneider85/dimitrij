module Dimitrij::Commands::Roll
  RESULTS = %w[1⃣ 2⃣ 3⃣ 4⃣ 5⃣ 6⃣].freeze
  NUMBER_OF_DICES = 4

  extend Discordrb::Commands::CommandContainer
  command(:roll, description: '[1-4] Roll a dice.') do |_event, number|
    number = number.to_i % 5
    if number > 1
      (1..number).to_a.map { roll }.join(' ')
    else
      roll
    end
  end

  def self.roll
    RESULTS.sample
  end
end
