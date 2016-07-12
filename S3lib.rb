#!/usr/local/bin/ruby -w
# S3lib.rb

module S3

  module Authorized
    # Enter your public key (Amazon calls it an "Access Key ID") and
    # your private key (Amazon calls it a "Secret Access Key"). This is
    # so you can sign your S3 requests and Amazon will know who to
    # charge.

    class << self
      attr_accessor :public_key
      attr_accessor :private_key
    end

    @public_key = ''
    @private_key = ''

    if @public_key.empty? or @private_key.empty?
      raise "You need to set your S3 keys!"
    end

    # Amazon S3 endpoint
    HOST = 'https://s3.amazonaws.com/'
  end

end