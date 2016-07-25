#!/bin/ruby
require 'optparse'

require_relative 'lib/Images.rb'
require_relative 'lib/RegistryV1ClientAPI.rb'
require_relative 'lib/Registry.rb'

options = {}
options[:ssl] = false
options[:dry] = false
OptionParser.new do |opts|
  opts.banner = "Usage: ./clean-registry.rb [options]"

  opts.on('-h', '--host HOST', 'Host') { |v| options[:host] = v }
  opts.on('-p', '--port PORT', 'Port') { |v| options[:port] = v }
  opts.on('--ssl', 'SSL') { options[:ssl] = true }
  opts.on('--dry', 'Dry Run') { options[:dry] = true }
  opts.on('-n', '--numberToKeep NUMBER', 'Number of tags to keep') { |v| options[:numberToKeep] = v }

end.parse!

abort 'Missing option : -h HOSTNAME' if options[:host].nil?
abort 'Missing option : -n NUMBER' if options[:numberToKeep].nil?

if options[:port].nil?
  options[:port] = 5000
  puts "Missing port (-p PORT), set to default : 5000"
end

if options[:ssl]
  proto='https://'
else
  proto='http://'
end

if options[:dry]
  puts "Launch in dry-run mode, the registry will not be cleaned"
end

baseUrl=proto+options[:host]+':'+options[:port].to_s+'/'
maxVersion = options[:numberToKeep].to_i

puts baseUrl

def cleanRegistry(baseUrl,maxVersion,dry)

  registry = Registry.new(baseUrl)

  images = registry.getAllImages()

  images.each { |x|
    images.delete_if {|y| y.name == x.name }
    imageTagsList = registry.getAllTagsFromImage(x.name)

    if imageTagsList.size > maxVersion

      imageTagsList = imageTagsList.sort { |x,y| y <=> x }

      keepList = Array.new
      while keepList.size < maxVersion and imageTagsList.size > 0 do
        if keepList.include?(imageTagsList.first.id)
          imageTagsList.delete(imageTagsList.first)
        else
          keepList.push(imageTagsList.first.id)
          imageTagsList.delete(imageTagsList.first)
        end
      end

      imageTagsList.each { |imageTag|
        cmd="curl -XDELETE "+baseUrl+"v1/repositories/"+imageTag.name+"/tags/"+imageTag.tag
        puts "Command : "+cmd
        unless dry
          %x`#{cmd}`
        end
      }
    end
  }
end

cleanRegistry(baseUrl,maxVersion,options[:dry])
