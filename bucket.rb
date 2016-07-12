module S3
  class Bucket
    include S3::Authorized
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    # The URI to the bucket is ROOT plus bucket_name
    def get_uri
      HOST + URI.escape(name)
    end


    # Stores this bucket on S3. Analogous to ActiveRecord::Base#save,
    # which stores an object in the database.
    def put(acl_policy = nil)

      # Set the HTTP method as an argument to 'open'
      args = {:method => :put}

      # Set S3 access policy for this bucket if one was provided.
      args['x-amz-acl'] = acl_policy if acl_policy

      # Send a put request to this bucket's URI
      open(get_uri, args)
    end

    # Delete this bucket. This will fail with HTTP status code 409("Conflict")
    # unless the bucket is empty
    def delete
      # Send a delete request to this bucket's URI.
      open(get_uri, :method => :delete)
    end

    # Get the objects in this bucket: all of them, or some subset.
    #
    # If S3 decides not to return the whole bucket/subset, the second
    # return value will be set to true. To get the rest of the objects,
    # you'll need to manipulate the subset options (not covered in the
    # book text).
    #
    # The subset options are :Prefix, :Marker, :Delimiter, :MaxKeys.
    # For details, see the S3 docs on "Listing Keys".
    def get(options = {})
      uri = get_uri_with_options(options)

      # Now we've built up our URI. Make a GET request to that URI and
      # read an XML document that lists objects in the bucket.
      doc = REXML::Document.new(open(uri).read)
      are_there_more = REXML::XPath.first(doc, '//IsTruncated').text == 'true'

      # Build a list of S#:Object objects.
      objects = []
      # For every object in the bucket...
      REXML::XPath.each(doc, '//Contents/Key') { |e|
        # ...build an S3::Object object and append it to the list.
        objects << Object.new(self, e.text) if e.text
      }

      return objects, are_there_more
    end


    private

    # Get the base URI to this bucket. and append any subset options
    # onto the query string
    def get_uri_with_options(options)
      uri = get_uri
      suffix = '?'

      # for every option the user provided...
      options.each { |param, value|
        # if it is one of the subset options...
        if [:Prefix, :Marker, :Delimiter, :MaxKeys].member? :param
          # ...add it to the uri
          uri << suffix << param.to_s << '=' << URI.escape(value)
          suffix = '&'
        end
      }

      uri
    end

  end
end








































