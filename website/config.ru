
$:.unshift './sinatra/lib'
$:.unshift '.'

require 'sinatra'
Sinatra::Application.default_options.merge!({
  :run => false,
  :env => :production
})

require 'website'
run Sinatra.application

