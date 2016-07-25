#!/bin/ruby

class Registry
  attr_accessor :url, :registryApi

  def initialize(url)
    @url=url
    @registryApi=RegistryV1ClientAPI.new(url)
  end

  #Method to return an Array of Images object
  def getAllImages()
    imageList = Array.new

    #Get all images from the repo, with a call on : GET /v1/search
    allImage=registryApi.getImageList()

    allImage["results"].each { |item|

      #For each images, get all the related tags, with a call on : GET /v1/repositories/(namespace)/(repository)/tags
      imageTags = registryApi.getImageTagList(item["name"])

      #For each images, create an object, with his tag, his name and his associated date
      imageTags.each { |tag , id|
        imageTagInfo = registryApi.getImageTagInfoList(id)
        t = Images.new(id,tag,imageTagInfo["created"],item["name"])
        imageList.push(t)
      }
    }
    return imageList;
  end

  #Method to return all tags from a specific image (need the name of the image)
  def getAllTagsFromImage(name)
    image=registryApi.getImageTagList(name)

    imageList = Array.new

    image.each{ |tag , id|
      imageTagInfo = registryApi.getImageTagInfoList(id)
      t = Images.new(id,tag,imageTagInfo["created"],name)
      imageList.push(t)
    }
    return imageList
  end

  #Method to return one unique image tag (need the name and the tag)
  def getUnicTagFromImage(name,tag)
    image=registryApi.getImageTagList(name)

    image.each{ |imageTag , imageId|
      if tag == imageTag
        imageTagInfo = registryApi.getImageTagInfoList(imageId)
        imageSpecificTag = Images.new(imageId,imageTag,imageTagInfo["created"],name)
        return imageSpecificTag
      end
    }
  end
end
