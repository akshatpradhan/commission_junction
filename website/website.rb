
require 'rubygems'
require 'sinatra'

load '../lib/commission_junction.rb'

Services = {
  "productSearch"    => ["products", "Product"],
  "searchLinks"      => ["links", "LinkDetail"],
  "advertiserSearch" => ["advertisers", "AdvertiserData"]
}

get '/' do
  haml :index
end

post '/search' do
  cj = CommissionJunction.new("00a3cf9d83c55966185b7c0b00639eed47bbc6b7a74796082eb010a20f17529e9db0b75b18a8ffae21874a3012eba6e1f1b8f4b01e48cc3fdf8a4914896a7087d7/717d9cd6b77ac9962483db2768dda9ed21f67a34e60ed71a69970c80421b569233288e80d652d00b2af4b18aa778fc804946c2bb03e5b1ffde27eda03b9d0729", "3107574")
  service = params.delete("service")
  soap_result = cj.send(service, params)
  results = soap_result[Services[service][0]][Services[service][1]]
  haml :index, :locals => {:cj => cj, :results => results, :params => params, :service => service}
end
