# ----------------------------------------------
#  Class for Vimeo (vimeo.com)
#  http://vimeo.com/5362441
# ----------------------------------------------


class VgVimeo

  def initialize(url=nil, options={})
    # general settings
    @url = url
    @video_id = parse_url(url)

    if !(@vimeo_id =~ /^[0-9]+$/)
      r = Net::HTTP.get_response(URI.parse(url))

      if r.code == "301"
        @url = "http://vimeo.com#{r.header['location']}"
        @video_id = parse_url(@url)
      end
    end

    res = Net::HTTP.get(URI.parse("http://vimeo.com/api/v2/video/#{@video_id}.xml"))
    @feed = REXML::Document.new(res)
  end

  def video_id
    @video_id
  end

  def title
    REXML::XPath.first( @feed, "//title" )[0].to_s
  end

  def thumbnail
    REXML::XPath.first( @feed, "//thumbnail_medium" )[0].to_s
  end

  def duration
    REXML::XPath.first( @feed, "//duration" )[0].to_s.to_i
  end

  def embed_url
    "http://vimeo.com/moogaloop.swf?clip_id=#{@video_id}&amp;force_embed=1&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=1&amp;color=ffffff&amp;fullscreen=1&amp;autoplay=0&amp;loop=0"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='#{embed_url}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='#{width}' height='#{height}'></embed></object>"
  end

  def flv
    res = Net::HTTP.get(URI.parse("http://vimeo.com/42966264?action=download"))
    request_signature = res.split("\"signature\":\"")[1].split("\"")[0]
    request_cached_timestamp = res.split("\"cached_timestamp\":")[1].split(",")[0]
    "http://player.vimeo.com/play_redirect?clip_id=#{@video_id}&sig=#{request_signature}&time=#{request_cached_timestamp}&quality=sd&codecs=H264,VP8,VP6&type=moogaloop&embed_location="
  end
  
  def download_url
    request_signature = REXML::XPath.first( @feed, "//request_signature" )[0]
    request_signature_expires = REXML::XPath.first( @feed, "//request_signature_expires" )[0]
    "http://www.vimeo.com/moogaloop/play/clip:#{@video_id}/#{request_signature}/#{request_signature_expires}/?q=hd"
  end

  def service
    "Vimeo"
  end

  protected

  # formats: http://vimeo.com/<video_id> or http://vimeo.com/channels/hd#<video_id>
  def parse_url(url)
      uri = URI.parse(url)
      path = uri.path
      videoargs = ''
            
      return uri.fragment if uri.fragment
      
      if uri.path and path.split("/").size > 0
        videoargs = path.split("/")
        raise unless videoargs.size > 0
      else
        raise
      end
      videoargs[1]
    rescue
      nil    
  end
  
end
