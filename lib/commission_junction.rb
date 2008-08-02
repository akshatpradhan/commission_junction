$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'soap/wsdlDriver'
require 'commission_junction/ext'

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
#   pp results
#   
#   Outputs:
#   # {"totalResults"=>"1200",
#   #  "count"=>"10",
#   #  "links"=>
#   #   {"LinkDetail"=>
#   #     [{"threeMonthEPC"=>"-9999999.0",
#   #       "sevenDayEPC"=>"-9999999.0",
#   #       "promotionType"=>{},
#   #       "linkDestination"=>
#
# Another example, using 'sortBy', shown in the web services documentation
#   results = cj.searchLinks(:keywords => "kitchen sink", :sortBy => "linkId")
#
#   pp results
#   
#   Outputs:
#   # {"totalResults"=>"1200",
#   #  "count"=>"10",
#   #  "links"=>
#   #   {"LinkDetail"=>
#   #     [{"threeMonthEPC"=>"-9999999.0",
#   #       "sevenDayEPC"=>"-9999999.0",
#   #       "promotionType"=>{},
#   #       "linkDestination"=>
#   #        "http://www.vintagetub.com/asp/sinks.asp?utm_id=ID2001",
#   #       "relationshipStatus"=>"notjoined",
#   #       "linkId"=>"10411673",
#   #       "category"=>"bed & bath",
#   #       "linkCodeJavascript"=>{},
#

class CommissionJunction
  module VERSION 
    MAJOR = 1
    MINOR = 0
    TINY  = 2

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

  def initialize(developerKey, websiteId)
    @developerKey, @websiteId = developerKey, websiteId
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
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Publisher_Lookup_Service.htm
  #
  def publisherLookup(token)
    doOperation('PublisherLookup', 'publisherLookup', self.instance_variables_hash.merge({:token => token}))
  end

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCategories(locale = 'US')
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
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCountries(locale = 'US')
    doOperation('FieldTypesSupport', 'getCountries', self.instance_variables_hash.merge({:locale => locale}))
  end

  #
  # For a list of possible params (where applicable) or more information, go to:
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLanguages
    doOperation('FieldTypesSupport', 'getLanguages', self.instance_variables_hash)
  end

  protected
  def doOperation(service, method, params)
    factory = SOAP::WSDLDriverFactory.new(@@wsdls[service])
    driver = factory.create_rpc_driver
    driver.send(method, params).to_hash["out"]
  end
end
