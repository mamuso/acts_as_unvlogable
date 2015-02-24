# ----------------------------------------------
#  Class for Wistia (wistia.com)
#  https://home.wistia.com/medias/e4a27b971d
# ----------------------------------------------

# We are using Wistia's SEO embed
# http://wistia.com/doc/construct-an-embed-code#video_seo_embed_tutorial

require "cgi"
require "json"
require "net/http"

class VgWistia
  class NotAvailable < StandardError; end

  attr_reader :title, :thumbnail, :duration, :service

  def initialize(url=nil, options={})
    @url = url
    fetch_video_details!
    assign_properties!
  end

  def embed_url
    raise NotAvailable, "Please use `#embed_html` instead"
  end

  def flv
    raise NotAvailable, "flv format not available. Please use `#embed_html` instead"
  end

  def embed_html(*args)
    @embed_html
  end

  private

  def fetch_video_details!
    begin
      res = Net::HTTP.get(URI.parse(wistia_oembed_endpoint))
      @details = JSON.parse(res)
    rescue JSON::ParserError
      raise ArgumentError, "Unsupported url or service"
    end
  end

  def assign_properties!
    @title      = @details["title"]
    @thumbnail  = @details["thumbnail_url"]
    @duration   = @details["duration"]
    @embed_html = @details["html"]
    @service    = @details["provider_name"]
  end

  def encoded_url
    CGI::escape(@url + "?embedType=seo")
  end

  def wistia_oembed_endpoint
    "http://fast.wistia.com/oembed.json?url=#{encoded_url}"
  end
end
