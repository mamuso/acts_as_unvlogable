# ----------------------------------------------
#  Class for Vimeo (vimeo.com)
#  http://vimeo.com/5362441
# ----------------------------------------------


class VgVimeo

  def initialize(url=nil, options={})
    # general settings
    @url = url
    @video_id = parse_url(url)
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
    "http://player.vimeo.com/video/#{@video_id}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe src='#{embed_url}' width='#{width}' height='#{height}' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>" 
  end
  
  def download_url
    nil
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
