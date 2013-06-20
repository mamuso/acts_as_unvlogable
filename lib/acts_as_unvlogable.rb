require "rubygems"
require "bundler/setup"

require "xmlsimple"
require "youtube_it"
require "hpricot"
require "net/http"
require "json"

require "acts_as_unvlogable/flickr"
# Extensions
if defined?(ActiveSupport).nil?
  require "acts_as_unvlogable/string_base"
  require "acts_as_unvlogable/object_base"
end
require "acts_as_unvlogable/string_extend"

# Video classes
videolibs = File.join(File.dirname(__FILE__), "acts_as_unvlogable", "vg_*.rb")
Dir.glob(videolibs).each {|file| require file}

class UnvlogIt
  
  def initialize(url=nil, options={})
    @object = VideoFactory.new(url, options).load_service
  end
  
  def title
    @object.title #rescue nil
  end
  
  def thumbnail
    @object.thumbnail rescue nil
  end
  
  def duration # duration is in seconds
    @object.duration rescue nil
  end
  
  def embed_url
    @object.embed_url rescue nil
  end
  
  def video_id
    @object.video_id rescue nil
  end

  def embed_html(width=425, height=344, options={}, params={})
    @object.embed_html(width, height, options, params) rescue nil
  end
  
  def flv
    @object.flv #rescue nil
  end
  
  def download_url
    @object.download_url rescue nil
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
      :download_url => @object.download_url,
      :service => @object.service,
      :duration => @object.duration
    }
  end

  class VideoFactory
    def initialize(url, options = {})
      raise ArgumentError.new("We need a video url") if url.blank?
      @url     = url
      @options = options
    end

    def load_service
      @object = service_object

      validate_embed(@object)
    end

    private

    def validate_embed(object)
      unless object.instance_variable_get("@details").nil? || !object.instance_variable_get("@details").respond_to?("noembed")
        if object.instance_variable_get("@details").noembed
          raise ArgumentError.new("Embedding disabled by request")
        end
      end
      object
    end

    def service_object
      class_name = "vg_#{get_domain.downcase}".camelize
      class_name.constantize.new(@url, @options)
    rescue NameError
      raise ArgumentError.new("Unsuported url or service. class: #{class_name}, url: #{@url}")
    end

    def get_domain
      host = URI::parse(@url).host.split(".")
      unless host.size == 1
        host[host.size-2]
      else
        host[0]
      end
    end
  end
end
