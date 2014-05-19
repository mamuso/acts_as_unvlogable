# ----------------------------------------------
#  Class for Dailymotion (www.dailymotion.com)
#  http://www.dailymotion.com/visited-week/lang/es/video/x7u5kn_parkour-dayyy_sport
# ----------------------------------------------


class VgDailymotion
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://www.dailymotion.com/rss/video/#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//item/title")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//media:thumbnail").attributes['url'].gsub("preview_large", "preview_medium")
  end
  
  def embed_url
    REXML::XPath.first(@feed, "//media:content[@type='text/html']").attributes['url']
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe frameborder='0' width='#{width}' height='#{height}' src='#{embed_url}' allowfullscreen></iframe>"
  end
  
  def flv
    doc = URI::parse("http://dailymotion.com/embed/video/#{@video_id}").read
    doc = URI::parse("#{doc.split("stream_h264_url\":\"")[1].split("\"")[0].gsub("\\", "")}&redirect=0").read
  end 

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Dailymotion"
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      path = uri.path
      videoargs = ''
      if path
        videoargs = path.split('/video/')[1].split("/")[0]
        raise unless videoargs.size > 0
      else
        raise
      end
      videoargs
    rescue
      nil
  end
  
  
end