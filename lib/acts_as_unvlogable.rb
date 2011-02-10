# Included gems
require 'youtube_it'
require 'acts_as_unvlogable/flickr'
# Extensions
if defined?(ActiveSupport).nil?
  require 'acts_as_unvlogable/string_base'
  require 'acts_as_unvlogable/object_base'
end
require 'acts_as_unvlogable/string_extend'

# Video classes
videolibs = File.join(File.dirname(__FILE__), "acts_as_unvlogable", "vg_*.rb")
Dir.glob(videolibs).each {|file| require file}

class UnvlogIt
  
  def initialize(url=nil, options={})
    raise ArgumentError.new("We need a video url") if url.blank?
    @object ||= "vg_#{get_domain(url).downcase}".camelize.constantize.new(url, options) rescue nil
                raise ArgumentError.new("Unsuported url or service") and return if @object.nil?
                unless @object.instance_variable_get("@details").nil? || !@object.instance_variable_get("@details").respond_to?("noembed")
                  raise ArgumentError.new("Embedding disabled by request") and return if @object.instance_variable_get("@details").noembed
                end
  end
  
  def title
    @object.title #rescue nil
  end
  
  def thumbnail
    @object.thumbnail rescue nil
  end
  
  def embed_url
    @object.embed_url rescue nil
  end

  def embed_html(width=425, height=344, options={})
    @object.embed_html(width, height, options) rescue nil
  end
  
  def flv
    @object.flv rescue nil
  end

  def service
    @object.service rescue nil
  end
  
  def video_details(width=425, height=344)
    {
      :title => @object.title,
      :thumbnail => @object.thumbnail,
      :embed_url => @object.embed_url,
      :embed_html => @object.embed_html(width, height),
      :flv => @object.flv,
      :service => @object.service
    }
  end

  
  def get_domain(url)
    host = URI::parse(url).host.split(".")
    unless host.size == 1
      host[host.size-2]
    else
      host[0]
    end
  end
  
end