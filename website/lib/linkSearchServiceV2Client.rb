#!/usr/bin/env ruby

Object.class_eval do
  def ivars_hash
    instance_variables.inject({}) {|hash, name| hash[name.gsub("@", "")] = instance_variable_get(name); hash }
  end
end


# SYNOPSIS
#   searchLinks(parameters)
#
# ARGS
#   parameters      SearchLinks - {http://api.cj.com}searchLinks
#
# RETURNS
#   parameters      SearchLinksResponse - {http://api.cj.com}searchLinksResponse
#

class SearchLinks
  attr_accessor :developerKey
  attr_accessor :token
  attr_accessor :websiteId
  attr_accessor :advertiserIds
  attr_accessor :keywords
  attr_accessor :category
  attr_accessor :linkType
  attr_accessor :linkSize
  attr_accessor :language
  attr_accessor :serviceableArea
  attr_accessor :promotionType
  attr_accessor :promotionStartDate
  attr_accessor :promotionEndDate
  attr_accessor :sortBy
  attr_accessor :sortOrder
  attr_accessor :startAt
  attr_accessor :maxResults

  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def keywords
    @keywords || "kitchen sink"
  end

  def developerKey
    @developerKey || "00a3cf9d83c55966185b7c0b00639eed47bbc6b7a74796082eb010a20f17529e9db0b75b18a8ffae21874a3012eba6e1f1b8f4b01e48cc3fdf8a4914896a7087d7/717d9cd6b77ac9962483db2768dda9ed21f67a34e60ed71a69970c80421b569233288e80d652d00b2af4b18aa778fc804946c2bb03e5b1ffde27eda03b9d0729"
  end

  def websiteId
    @websiteId || "3107574"
  end

  def searchLinks
    search = LinkSearchServiceV2PortType.new
    search.searchLinks(self)
  end
end

# # run ruby with -d to see SOAP wiredumps.
# obj.wiredump_dev = STDERR if $DEBUG

require File.dirname(__FILE__) + '/defaultDriver.rb'

