# Libraries necesary for making HTTP requests and parsing responses
require 'rubygems'
require 'rest-open-uri'
require 'rexml/document'

module S3
  # The bucket list...
  class BucketList
    include S3::Authorized

    def get
      buckets = []

      # GET the bucket list URI and read an XML documents from it
      doc = REXML::Document.new(open(HOST).read)

      # For every bucket...
      REXML::XPath.each(doc, '//Bucket/Name') { |e|
        # ... creates a new bucket object and add it to the list
        buckets << Bucket.new(e.text) if e.text
      }

      buckets
    end
  end
end