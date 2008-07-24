$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'soap/wsdlDriver'

Array.class_eval do
  def to_hash
    self.inject({}) do |hash, pair|
      hash[pair[0]] = pair[1]
      hash
    end
  end
end

Hash.class_eval do
  def to_struct
    return {} if empty?
#    raise "Cannot convert an empty hash into a struct!" if empty?
    keys = self.keys.map {|k| k.to_sym }
    Struct.new(*keys).new(*(self.values))
  end
end

Object.class_eval do
  def instance_variables_hash
    instance_variables.inject({}) {|hash, name| hash[name.gsub("@", "")] = instance_variable_get(name); hash }
  end
end

SOAP::Mapping::Object.class_eval do
  def to_object
    __xmlele.map do |qname, value| 
      value = if value.is_a? SOAP::Mapping::Object
                value.to_object
              elsif value.is_a? Array
                value.map {|v| v.is_a?(SOAP::Mapping::Object) ? v.to_object : v }
              else
                value
              end
      [qname.name, value] 
    end.to_hash.to_struct
  end
end

class CommissionJunction
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
  # http://help.cj.com/en/web_services/Product_Catalog_Search_Service_v.2.htm
  #
  def productSearch(params = {})
    doOperation('ProductSearch', __method__, self.instance_variables_hash.merge(params))
  end

  # 
  # http://help.cj.com/en/web_services/Link_Search_Service_v.2.htm
  #
  def searchLinks(params = {})
    doOperation('LinkSearch', __method__, self.instance_variables_hash.merge(params))
  end  

  #
  # http://help.cj.com/en/web_services/Publisher_Commission_Service.htm
  # 
  def findPublisherCommissions(params = {})
    doOperation('PublisherCommission', __method__, self.instance_variables_hash.merge(params))
  end
  
  #
  # http://help.cj.com/en/web_services/Publisher_Commission_Service.htm
  # 
  def findPublisherCommissionDetails(params = {})
    doOperation('PublisherCommission', __method__, self.instance_variables_hash.merge(params))
  end
  
  #
  # http://help.cj.com/en/web_services/Real_Time_Commission_Service.htm
  # 
  def retrieveLatestTransactions(params = {})
    doOperation('RealTimeCommission', __method__, self.instance_variables_hash.merge(params))
  end
  
  #
  # http://help.cj.com/en/web_services/Advertiser_Search_Service_v.2.htm
  #
  def advertiserSearch(params = {})
    doOperation('AdvertiserSearch', 'search', self.instance_variables_hash.merge(params))
  end

  #
  # http://help.cj.com/en/web_services/Publisher_Lookup_Service.htm
  #
  def publisherLookup(token)
    doOperation('PublisherLookup', __method__, self.instance_variables_hash.merge({:token => token}))
  end

  #
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCategories(locale = 'US')
    doOperation('FieldTypesSupport', __method__, self.instance_variables_hash.merge({:locale => locale}))
  end

  #
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLinkTypes
    doOperation('FieldTypesSupport', __method__, self.instance_variables_hash)
  end
  
  #
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLinkSizes
    doOperation('FieldTypesSupport', __method__, self.instance_variables_hash)
  end

  #
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getCountries(locale = 'US')
    doOperation('FieldTypesSupport', __method__, self.instance_variables_hash.merge({:locale => locale}))
  end

  #
  # http://help.cj.com/en/web_services/Support_Services.htm
  #
  def getLanguages
    doOperation('FieldTypesSupport', __method__, self.instance_variables_hash)
  end

  def doOperation(service, method, params)
    factory = SOAP::WSDLDriverFactory.new(@@wsdls[service])
    driver = factory.create_rpc_driver
    driver.send(method, params).to_object
  end
end
