=begin

This will upload all folders and files from your public folder into your Amazon S3 bucket.
The script creates a file called .aws_cache in the root of your application folder. This is used so that additional calls to rake aws:sync only uploads new and modified files.
If you have already uploaded your files before applying this script, you can start by calling
# rake aws:build_cache

This will build the local cachefiles without uploading anything to Amazon S3.

=end


require 'find'
require 'digest/md5'
require 'yaml'

#########################################################
# Configuration - these lines are all you need to edit
ACCESS_KEY_ID     = "your-own-aws-access-key"
SECRET_ACCESS_KEY = "and-the-secret-key"
BUCKET             = "name-of-your-bucket"

# If you have any subfolders inside "public", that you do not want to place on AWS, list them here
IGNORE_FOLDERS    = %w(upload UserFiles videos)
#########################################################

class AwsCache
  def initialize
    @filename = ".aws_cache"
    load
  end

  def clear
    @cache = {}
  end

  def load
    clear
    if File.exists?(@filename)
      @cache = YAML::load_file(@filename)
    end
  end

  def save
    File.open(@filename, "w") do |f|
      f.puts @cache.to_yaml
    end
  end

  def add(path)
    puts "add to cache: #{path}"
    @cache[path] = checksum(path)
  end

  def equal?(path)
    c = checksum(path)
    @cache[path] == c
  end

  protected
  def checksum(path)
    Digest::MD5.file(path).hexdigest
  end
end

namespace :aws do
  desc "Synchronize public folder"
  task :sync => :environment do
    init

    AWS::S3::Base.establish_connection!(
      :access_key_id     => ACCESS_KEY_ID,
      :secret_access_key => SECRET_ACCESS_KEY
    )

    bucket = AWS::S3::Bucket.find(@bucket)

    loop_folder()

    @aws_cache.save
  end

  desc "Rebuild local cache file"
  task :build_cache => :environment do
    init

    absolute_folder = File.join(@base_folder, "")

    Find.find(absolute_folder) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune
        elsif IGNORE_FOLDERS.include?(File.basename(path))
          Find.prune
        end
      else
        @aws_cache.add(path)
      end
    end

    @aws_cache.save
  end
end

def init
  @base_folder = File.join(RAILS_ROOT, "public")
  @bucket      = BUCKET
  @aws_cache   = AwsCache.new
end

def loop_folder(folder = "")
  absolute_folder = File.join(@base_folder, folder)

  total_size = 0

  Find.find(absolute_folder) do |path|
    if FileTest.directory?(path)
      if File.basename(path)[0] == ?.
        Find.prune
      elsif IGNORE_FOLDERS.include?(File.basename(path))
        Find.prune
      else
        next
      end
    else
      s3_store(path)
    end
  end
end

def s3_store(path)
  s3_path = path.gsub("#{@base_folder}/", '')

  if transfer?(path)
    AWS::S3::S3Object.store(
      s3_path,
      open(path),
      @bucket,
      :access => :public_read)

    puts "Stored into AWS: #{AWS::S3::S3Object.url_for(s3_path, @bucket)[/[^?]+/]}"
  end
end

def transfer?(path)
  return false if @aws_cache.equal?(path)

  @aws_cache.add(path)
  return true
end