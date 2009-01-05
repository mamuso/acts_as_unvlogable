# ----------------------------------------------
#  Class for Dailymotion (www.dailymotion.com)
#  http://www.dailymotion.com/visited-week/lang/es/video/x7u5kn_parkour-dayyy_sport
# ----------------------------------------------


class VgDailymotion
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://www.dailymotion.com/atom/video/#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//title")[0].to_s
  end
  
  def thumbnail
    th = URI.parse REXML::XPath.first(@feed, "//link[@type='image/jpeg']").attributes['href']
    "http://#{th.host}/dyn/preview/160x120/#{th.path.split("/").pop}"
  end
  
  def embed_url
    REXML::XPath.first(@feed, "//link[@type='application/x-shockwave-flash']").attributes['href']
  end

  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}&related=1'></param><param name='allowFullScreen' value='true'></param><param name='allowScriptAccess' value='always'></param><embed src='#{embed_url}&related=1' type='application/x-shockwave-flash' width='#{width}' height='#{height}' allowFullScreen='true' allowScriptAccess='always'></embed></object>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//link[@type='video/x-flv']").attributes['href']
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      path = uri.path
      videoargs = ''
      if path
        videoargs = path.match(/x.*/)[0]
        raise unless videoargs.size > 0
      else
        raise
      end
      videoargs
    rescue
      nil
  end
  
  
end