#!/bin/env ruby

## top directory of movie files

TOP='/home/share/media/movie'

##### Job queue #####

require 'thread'

queue = Queue.new
thread = Thread.start do
  while target = queue.pop
    puts '============================================================'
    puts 'Converting : ' + target[:file]
    puts '============================================================'
    mp4file = "/tmp/avconv/" + File.basename(target[:file]).sub(/MTS/, 'mp4')
    if target[:transpose]
      command = "avconv -i #{target[:file]} -y -vf transpose=#{target[:transpose]} -strict experimental #{mp4file}"
    else
      command = "avconv -i #{target[:file]} -y -strict experimental #{mp4file}"
    end
    command = ["mkdir /tmp/avconv",
               command,
               "touch -r #{target[:file]} #{mp4file}",
               "mv -f #{mp4file} #{target[:file].sub(/MTS/, 'mp4')}",
               "rmdir /tmp/avconv"].join(";")
    system(command)
  end
end

##### Web server #####

require 'sinatra'
require 'haml'

set :bind, '0.0.0.0'

set :public_folder, TOP

get '/' do
  redirect '/view/'
end

get '/view' do
  redirect '/view/'
end

get '/view/*' do
  @top = TOP
  @entry = params[:splat].first
  redirect "/#{@entry}" if @entry[/\.(mp4|3gp)$/]
  @files = Dir.entries(TOP + '/' + @entry).select{|x| x[0] != "."}.sort
  haml :view
end

get '/thumb/*' do
  file = TOP + '/' + params[:splat].first
  content_type 'image/jpeg'
  `avconv -v quiet -i #{file} -f image2 -ss 0.01 -t 0.01 -vframes 1 -`
end

get '/conv/*' do
  queue.push({:file => TOP + '/' + params[:splat].first, :transpose => params[:transpose]})
  redirect back
end

get '/queue' do
  @queue = queue.instance_variable_get('@que')
  haml :queue
end
