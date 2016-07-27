#!/bin/ruby
require 'optparse'

require_relative 'lib/Images.rb'
require_relative 'lib/RegistryV1ClientAPI.rb'
require_relative 'lib/Registry.rb'

options = {}
options[:ssl] = false
options[:dry] = false
OptionParser.new do |opts|
  opts.banner = "Usage: ./mirror-registry.rb [options]"

  opts.on('--sourcehost HOST', 'Source host') { |v| options[:source_host] = v }
  opts.on('--sourceport PORT', 'Source port') { |v| options[:source_port] = v }
  opts.on('--destinationhost HOST', 'Destination host') { |v| options[:destination_host] = v }
  opts.on('--destinationport PORT', 'Destination port') { |v| options[:destination_port] = v }
  opts.on('--ssl', 'SSL') { options[:ssl] = true }
  opts.on('--dry', 'Dry Run') { options[:dry] = true }

end.parse!

abort 'Missing option : --sourcehost HOST' if options[:source_host].nil?
abort 'Missing option : --destinationhost HOST' if options[:destination_host].nil?

if options[:source_port].nil?
  options[:source_port] = 5000
  puts "Missing port (-p --sourceport PORT), set to default : 5000"
end

if options[:destination_port].nil?
  options[:destination_port] = 5000
  puts "Missing port (-p --destinationport PORT), set to default : 5000"
end

if options[:ssl]
  proto='https://'
else
  proto='http://'
end

if options[:dry]
  puts "Launch in dry-run mode, the registry will not be migrated"
end

dnsRegistryOrigin=options[:source_host]+':'+options[:source_port].to_s+'/'
dnsRegistryTarget=options[:destination_host]+':'+options[:destination_port].to_s+'/'
baseUrlOrigin=proto+dnsRegistryOrigin
baseUrlTarget=proto+dnsRegistryTarget

# Get all images from the first Registry
registryOrigin=Registry.new(baseUrlOrigin)
imagesOrigin=registryOrigin.getAllImages()

# Get all images from the second Registry
registryTarget=Registry.new(baseUrlTarget)
imagesTarget=registryTarget.getAllImages()

#Compare the two arrays, and keep only the non-transferred images
def compareImages(imagesOrigin,imagesTarget)
  pushList = Array.new
  imagesOrigin.each { |x|
    unless imagesTarget.include?(x)
      pushList.push(x)
    end
  }
  return pushList
end

#Migration part : pull image one by one -> tag with the new repo -> push in the new repo -> removing image to keep a clean local docker
def pushImages(imagesToPush,baseUrlOrigin,dnsEntryOrigin,dry)
  imagesToPush.each { |imageTag|
    cmd="sudo docker pull "+dnsEntryOrigin+imageTag.name+":"+imageTag.tag
    puts "Command : "+cmd
    unless dry
      %x`#{cmd}`
    end
    cmd="sudo docker tag "+dnsEntryOrigin+imageTag.name+":"+imageTag.tag+" "+dnsEntryTarget+imageTag.name+":"+imageTag.tag
    puts "Command : "+cmd
    unless dry
      %x`#{cmd}`
    end
    cmd="sudo docker push "+dnsEntryTarget+imageTag.name+":"+imageTag.tag
    puts "Command : "+cmd
    unless dry
      %x`#{cmd}`
    end
    cmd="sudo docker rmi -f "+dnsEntryOrigin+imageTag.name+":"+imageTag.tag+" "+dnsEntryTarget+imageTag.name+":"+imageTag.tag
    puts "Command : "+cmd
    unless dry
      %x`#{cmd}`
    end

    imagesToPush.delete(imageTag)
    puts "Images left : "+imagesToPush.length.to_s
  }
end

pushList=compareImages(imagesOrigin,imagesTarget)

puts "imagesOrigin numbers : "+imagesOrigin.length.to_s
puts "imagesTarget numbers : "+imagesTarget.length.to_s
puts "Images to push : "+pushList.length.to_s

#Send an array of images to push to the second registry
pushImages(pushList,dnsRegistryOrigin,dnsRegistryTarget,options[:dry])
