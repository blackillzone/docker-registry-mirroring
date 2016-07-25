#!/bin/ruby
require 'net/http'
require 'json'

class RegistryV1ClientAPI

    attr_accessor :baseUrl

    def initialize(baseUrl)
      @baseUrl = baseUrl
    end

    def callUrl(url)
        uri = URI(baseUrl + url)
        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
            json = JSON.parse(res.body)
            return json
        else
            raise Unable to call +uri.to_s
        end
    end

    def getImageList()
        return callUrl('v1/search') 
    end

    def getImageTagList(image)
        return callUrl('v1/repositories/'+image+'/tags')
    end

    def getImageTagInfoList(imageid)
        return callUrl('v1/images/'+imageid+'/json')
    end

end
