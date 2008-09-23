
require 'rubygems'
require 'active_record'

class SearchLink < ActiveRecord::Base
  establish_connection(CommissionJunction::Config.parse!["database"])
  
  def self.update!
    cj = CommissionJunction.new
    categories = cj.getCategories["string"]
    categories.each do |category|
      puts "Querying #{category} for links"
      results = cj.searchLinks(:category => category, :maxResults => 100)
      links = results["links"]["LinkDetail"]

      unless links.nil?
        links.each do |result|
          SearchLink.create_from_query!(result)
        end
      end
    end
  end

  def self.create_from_query!(result)
    link = new
    result.each do |key, value|
      link.send("#{key}=", value) if key.is_a? Symbol and link.respond_to? key
    end
    link.save!
    link
  end
end
