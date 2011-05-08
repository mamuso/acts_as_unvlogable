# ----------------------------------------------
#  Class for Vimeo (vimeo.com)
#  http://vimeo.com/5362441
# ----------------------------------------------


class VgVimeo
  
  def initialize(url=nil, options={})
    # general settings
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://vimeo.com/moogaloop/load/clip:#{@video_id}/embed?param_server=vimeo.com&param_clip_id=#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def video_id
    @video_id
  end
  
  def title
    REXML::XPath.first( @feed, "//caption" )[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first( @feed, "//thumbnail" )[0].to_s
  end
  
  def duration
    REXML::XPath.first( @feed, "//duration" )[0].to_s.to_i
  end
  
  def embed_url
    "http://vimeo.com/moogaloop.swf?clip_id=#{@video_id}&server=vimeo.com&fullscreen=1&show_title=1&show_byline=1&show_portrait=1"
  end
  
  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='#{embed_url}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='#{width}' height='#{height}'></embed></object>"
  end

  def flv
    request_signature = REXML::XPath.first( @feed, "//request_signature" )[0]
    request_signature_expires = REXML::XPath.first( @feed, "//request_signature_expires" )[0]
    "http://www.vimeo.com/moogaloop/play/clip:#{@video_id}/#{request_signature}/#{request_signature_expires}/"
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