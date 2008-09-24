$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'soap/wsdlDriver'
require 'commission_junction/ext'

#
# = General Usage
#
# A fairly simple example of the library
#   require 'commission_junction'
#
# Your developer key
#   developerKey = "1234567890abc...."
#
# Your Web site ID (PID)
#   websiteId    = "1234567"
#
# A new instance of the Commission Junction service API
#   cj = CommissionJunction.new(developerKey, websiteId)
#
# A minimal search, using the keywords parameter
#   result = cj.searchLinks(:keywords => "kitchen sink")
#
# All CJ results are hashes.. I found this to be easier to
# use than objects because hashes are more transparent:
#
#   require 'pp'
#   pp results
#   
#   Outputs:
#    {"totalResults"=>"1200",
#     "count"=>"10",
#     "links"=>
#      {"LinkDetail"=>
#        [{"threeMonthEPC"=>"-9999999.0",
#          "sevenDayEPC"=>"-9999999.0",
#          "promotionType"=>{},
#          "linkDestination"=>
#
# Another example, using 'sortBy', shown in the web services documentation
#   results = cj.searchLinks(:keywords => "kitchen sink", :sortBy => "linkId")
#
#   pp results
#   
#   Outputs:
#    {"totalResults"=>"1200",
#     "count"=>"10",
#     "links"=>
#      {"LinkDetail"=>
#        [{"threeMonthEPC"=>"-9999999.0",
#          "sevenDayEPC"=>"-9999999.0",
#          "promotionType"=>{},
#          "linkDestination"=>
#           "http://www.vintagetub.com/asp/sinks.asp?utm_id=ID2001",
#          "relationshipStatus"=>"notjoined",
#          "linkId"=>"10411673",
#          "category"=>"bed & bath",
#          "linkCodeJavascript"=>{},
#
# = Configuration
# 
# If you don't want to pass your key and id on each instatiation of 
# of CommissionJunction, create a yaml file:
# 
#   $HOME/.commission_junction.yaml
# 
# With $HOME being, of course, your home directory. Then include:
# 
#   developerKey: "1234567890abc...."
#   websiteId: "1234567"
# 
#
# = Storage
# 
# For convenience and more "on demand" usage of searchLinks
# service, you can set up the ActiveRecord database table
# and model, instead of fetching it on every request. 
#
# Here's an example, 
#
# 1) First add your database information to the commission 
# junction config, mentioned above:
#   
#   developerKey: "1234567890abc...."
#   websiteId: "1234567"
#
#   database:
#     adapter: mysql
#     database: commission_junction
#     username: cj
#     host: localhost
#
# 2) Create your database:
# 
#   >> mysql -ucj
#
#   mysql> create database commission_junction;
# 
# 3) Then open up irb and run the migration to set up the
# table itself
# 
#   >> require 'rubygems'
#   >> require 'commission_junction'
#   >> 
#   >> CommissionJunction.migrate!
#
#   ==  CreateSearchLinks: migrating ==============================================
#   -- create_table(:search_links)
#      -> 0.1812s
#   ==  CreateSearchLinks: migrated (0.1817s) =====================================
#
#   => ["CreateSearchLinks"]
#  
# A more preferable method may be found so this step
# may change in the future, but for now it's adequate.
# 
# 4) Next you'll want to start loading it with content. 
# 
#   require 'commission_junction/search_link'
#   
#   SearchLink.update!
#   
# This should start to load your table with all the categories 
# available from Commission Junction. This may take awhile so
# you may want to schedule this at regular intervals instead
# of doing so by hand.
#
# Scheduling section coming soon..
# 

class CommissionJunction
  module VERSION 
    MAJOR = 1
    MINOR = 1
    TINY  = 0

    STRING = [MAJOR, MINOR, TINY].join('.')
  end

  @@wsdls = {
    'ProductSearch'       =>  'https://product.api.cj.com/wsdl/version2/productSearchServiceV2.wsdl',
    'LinkSearch'          =>  'https://product.api.cj.com/wsdl/version2/linkSearchServiceV2.wsdl',
    'PublisherCommission' =>  'https://product.api.cj.com/wsdl/version2/publisherCommissionService.wsdl',
    'RealTimeCommission'  =>  'https://product.api.cj.com/wsdl/version2/realtimeCommissionService.wsdl',
    'AdvertiserSearch'    =>  'https://product.api.cj.com/wsdl/version2/advertiserSearchServiceV2.wsdl',
    'PublisherLookup'     =>  'https://product.api.cj.com/wsdl/version2/publisherLookupService.wsdl',
    'FieldTypesSupport'   =>  'https://product.api.cj.com/wsdl/version2/supportServiceV2.wsdl'
  }

  #
  # If you've supplied the config file with the proper credentials
  # then you don't need to pass a key or id.
  #
  # Also, any values passed will overwrite the config file's values
  #
  def initialize(developerKey = nil, websiteId =nil)
    if File.exists?(Config.file)
      parse_config_file!
    end
    @developerKey ||= developerKey
    @websiteId    ||= websiteId
  end

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Product_Catalog_Search_Service_v.2.htm
  #
  def productSearch(params = {})
    doOperation('ProductSearch', 'search', self.instance_variables_hash.merge(params))
  end

  # 
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Link_Search_Service_v.2.htm
  #
  def searchLinks(params = {})
    doOperation('LinkSearch', 'searchLinks', self.instance_variables_hash.merge(params))
  end  
  alias :linkSearch :searchLinks

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Publisher_Commission_Service.htm
  # 
  def findPublisherCommissions(params = {})
    doOperation('PublisherCommission', 'findPublisherCommissions', self.instance_variables_hash.merge(params))
  end
  
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Publisher_Commission_Service.htm
  # 
  def findPublisherCommissionDetails(params = {})
    doOperation('PublisherCommission', 'findPublisherCommissionDetails', self.instance_variables_hash.merge(params))
  end
  
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Real_Time_Commission_Service.htm
  # 
  def retrieveLatestTransactions(params = {})
    doOperation('RealTimeCommission', 'retrieveLatestTransactions', self.instance_variables_hash.merge(params))
  end
  
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Advertiser_Search_Service_v.2.htm
  #
  def advertiserSearch(params = {})
    params[:startAt] ||= 0
    params[:maxResults] ||= 10
    doOperation('AdvertiserSearch', 'search', self.instance_variables_hash.merge(params))
  end

  #
  # Required parameters
  # token:  The Authentication Key from a successful publisher login. The Commission Junction authentication process generates this key and provides the developer with it. For example, after a publisher authenticates themselves with the Branded Login Service, the system appends the key to the specified redirect URL. 
  #
  # Response:
  # The response includes information about the publisher necessary for advertisers or developers to complete a number of tasks, including: creating links, personalizing content and identifying the publisher with their program.
  # 
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Publisher_Lookup_Service.htm
  #
  def publisherLookup(token)
    doOperation('PublisherLookup', 'publisherLookup', self.instance_variables_hash.merge({:token => token}))
  end

  #
  # List of advertiser sub-categories. Use a language code provided
  # by #getLanguages as your prefered locale (english is default).
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCategories(locale = 'en')
    doOperation('FieldTypesSupport', 'getCategories', self.instance_variables_hash.merge({:locale => locale}))
  end

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLinkTypes
    doOperation('FieldTypesSupport', 'getLinkTypes', self.instance_variables_hash)
  end
  
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLinkSizes
    doOperation('FieldTypesSupport', 'getLinkSizes', self.instance_variables_hash)
  end

  #
  # List of supported countries. Use a language code provided
  # by #getLanguages as your prefered locale (english is default).
  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCountries(locale = 'en')
    doOperation('FieldTypesSupport', 'getCountries', self.instance_variables_hash.merge({:locale => locale}))
  end

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLanguages
    doOperation('FieldTypesSupport', 'getLanguages', self.instance_variables_hash)
  end
  
  def database_enabled?
    not @database.nil?
  end

  protected
  def doOperation(service, method, params)
    factory = SOAP::WSDLDriverFactory.new(@@wsdls[service])
    driver = factory.create_rpc_driver
    driver.send(method, params).to_hash["out"]
  end

  def parse_config_file!
    config = Config.parse!
    @developerKey = config["developerKey"]
    @websiteId    = config["websiteId"]
    @database     = config["database"]
  end

  def self.migrate!
    db_connect!
    require 'commission_junction/migrate'
  end

  def self.db_connect!
    require 'active_record'
    config = CommissionJunction::Config.parse!
    ActiveRecord::Base.establish_connection(config["database"])
  end

  class Config
    #
    # The configuration file should be created at 
    # $HOME/.commission_junction
    #
    def self.file
      File.join(ENV['HOME'], ".commission_junction.yaml")    
    end
    
    def self.parse!
      YAML.load(File.read(file))      
    end
  end
end
