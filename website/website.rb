
require 'rubygems'
require 'sinatra'

load 'lib/linkSearchServiceV2Client.rb'

get '/' do
  haml :index
end

post '/search' do
  search = SearchLinks.new(params)
  results = search.searchLinks
  haml :index, :locals => {:search => search, :results => results, :params => params}
end
