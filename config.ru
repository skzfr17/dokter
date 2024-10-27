# config.ru
require 'sinatra'
require './app'  # Memastikan untuk memuat file app.rb

run Sinatra::Application