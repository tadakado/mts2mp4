#!/bin/env ruby

## top directory of movie files

TOP='/home/share/media/movie'

##### Job queue #####

require 'thread'

queue = Queue.new
queue_list = []
thread = Thread.start do
  while target = queue.pop
    queue_list.pop
    puts '============================================================'
    puts 'Converting : ' + target[:file]
    puts 'Transpose  : ' + transpose_num_to_str(target[:transpose])
    puts '============================================================'
    mp4file = "/tmp/avconv/" + File.basename(target[:file]).sub(/MTS/, 'mp4')
    if target[:transpose]
      command = "avconv -i #{TOP}/#{target[:file]} -y -vf transpose=#{target[:transpose]} -strict experimental #{mp4file}"
    else
      command = "avconv -i #{TOP}/#{target[:file]} -y -strict experimental #{mp4file}"
    end
    command = ["mkdir /tmp/avconv",
               command,
               "touch -r #{TOP}/#{target[:file]} #{mp4file}",
               "mv -f #{mp4file} #{TOP}/#{target[:file].sub(/MTS/, 'mp4')}",
               "rmdir /tmp/avconv"].join(";")
    system(command)
  end
end

##### func #####

def transpose_num_to_str(num)
  case num
  when '1'
    'Right'
  when '2'
    'Left'
  else
    'Normal'
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
  q = {:file => params[:splat].first, :transpose => params[:transpose]}
  queue.push(q)
  queue_list.push(q)
  redirect back
end

get '/queue' do
  @queue = queue_list
  haml :queue
end
