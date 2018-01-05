require 'rubygems'
require 'bundler/setup'
require 'discordrb'
require 'yaml'
require 'ostruct'
require 'byebug'

Settings = OpenStruct.new(YAML::load_file('config/discord.yml'))

Bot = Discordrb::Bot.new(token: Settings.token, client_id: Settings.client_id)
puts "This bot's invite URL is #{Bot.invite_url}."
