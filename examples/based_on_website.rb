
# A fairly simple example of the library

require 'commission_junction'

# Your developer key
developerKey = "1234567890abc...."

# Your Web site ID (PID)
websiteId    = "1234567"

# A new instance of the Commission Junction service API
cj = CommissionJunction.new(developerKey, websiteId)

# A minimal search, using the keywords parameter
result = cj.searchLinks(:keywords => "kitchen sink")

# All CJ results are hashes.. I found this to be easier to
# use than objects because hashes are more transparent:

pp results
# =>
# {"totalResults"=>"1200",
#  "count"=>"10",
#  "links"=>
#   {"LinkDetail"=>
#     [{"threeMonthEPC"=>"-9999999.0",
#       "sevenDayEPC"=>"-9999999.0",
#       "promotionType"=>{},
#       "linkDestination"=>

# Another example, using 'sortBy', shown in the web services documentation
results = cj.searchLinks(:keywords => "kitchen sink", :sortBy => "linkId")

pp results
# => 
# {"totalResults"=>"1200",
#  "count"=>"10",
#  "links"=>
#   {"LinkDetail"=>
#     [{"threeMonthEPC"=>"-9999999.0",
#       "sevenDayEPC"=>"-9999999.0",
#       "promotionType"=>{},
#       "linkDestination"=>
#        "http://www.vintagetub.com/asp/sinks.asp?utm_id=ID2001",
#       "relationshipStatus"=>"notjoined",
#       "linkId"=>"10411673",
#       "category"=>"bed & bath",
#       "linkCodeJavascript"=>{},
