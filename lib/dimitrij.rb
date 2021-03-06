require 'rubygems'
require 'yaml'

require 'bundler/setup'
Bundler.require(:default)

I18n.load_path = Dir['config/locales/*.yml']
I18n.backend.load_translations

require 'sqlite3'
require 'active_record'

ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db/dimitrij_database.db'
)
require_relative '../db/schema.rb'
require_relative 'dimitrij/application_record'
Dir["#{File.dirname(__FILE__)}/dimitrij/models/*.rb"].each { |file| require file }

module Dimitrij
  CONFIG = YAML.load_file('config/discord.yml')

  BOT = Discordrb::Commands::CommandBot.new(
    token: CONFIG['token'],
    client_id: CONFIG['client_id'],
    prefix: '!'
  )
  Discordrb::LOGGER.info "This bot's invite URL is #{BOT.invite_url}."

  require_relative 'dimitrij/commands'
  require_relative 'dimitrij/events'

  Dimitrij::Commands.include!
  Dimitrij::Events.include!

  BOT.run
end
