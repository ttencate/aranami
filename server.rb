#!/usr/bin/env ruby

require 'rake'
require 'sinatra'

rake = Rake::Application.new
Rake.application = rake
rake.init
rake.load_rakefile

get '/favicon.ico' do
  not_found
end

get '/*' do |filename|
  filename = 'index.html' if filename == ''
  task = Rake::Task[filename]
  task.reenable
  task.invoke
  send_file filename
end
