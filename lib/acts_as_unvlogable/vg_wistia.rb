# ----------------------------------------------
#  Class for Wistia (wistia.com)
#  https://home.wistia.com/medias/e4a27b971d
# ----------------------------------------------

class VgWistia
  attr_reader :title, :thumbnail, :duration, :service

  def initialize(url=nil, options={})
    @url = url
    fetch_video_details!
    assign_properties!
  end

  def embed_url
    iframe = Nokogiri::HTML(@details["html"])
    iframe.xpath("//iframe").first["src"]
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe src='#{embed_url}' allowtransparency='true' frameborder='0' scrolling='no' class='wistia_embed' name='wistia_embed' allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen width='#{width}' height='#{height}'></iframe>"
  end

  private

  def fetch_video_details!
    begin
      res = Net::HTTP.get(URI.parse(wistia_oembed_endpoint))
      @details = JSON.parse(res)
    rescue JSON::ParserError
      raise ArgumentError.new("Unsuported url or service")
    end
  end

  def assign_properties!
    @title      = @details["title"]
    @thumbnail  = @details["thumbnail_url"]
    @duration   = @details["duration"]
    @service    = @details["provider_name"]
  end

  def encoded_url
    CGI::escape(@url)
  end

  def wistia_oembed_endpoint
    "http://fast.wistia.com/oembed.json?url=#{encoded_url}"
  end
end
