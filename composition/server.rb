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
  begin
    task.invoke
  rescue RuntimeError
    print 'Rake error'
    status 500
    halt
  end
  send_file filename
end
