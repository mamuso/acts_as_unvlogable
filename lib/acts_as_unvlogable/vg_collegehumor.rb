# ----------------------------------------------
#  Class for Collegehumor (www.collegehumor.com)
#  http://www.collegehumor.com/video:1781938
# ----------------------------------------------


class VgCollegehumor
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://www.collegehumor.com/moogaloop/video/#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//video/caption")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//video/thumbnail")[0]
  end
  
  def embed_url
    "http://www.collegehumor.com/moogaloop/moogaloop.swf?clip_id=#{@video_id}&fullscreen=1"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object type='application/x-shockwave-flash' data='#{embed_url}' width='#{width}' height='#{height}'><param name='allowfullscreen' value='true'/><param name='wmode' value='transparent'/><param name='AllowScriptAccess' value='true'/><param name='movie' quality='best' value='#{embed_url}'/><embed src='#{embed_url}' type='application/x-shockwave-flash' wmode='transparent' width='#{width}' height='#{height}' allowScriptAccess='always'></embed></object>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//video/file")[0]
  end

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "CollegeHumor"
  end
  
  private

  def parse_url(url)
      uri = URI.parse(url)
      path = uri.path
      videoargs = path.split("/")
      raise unless videoargs.size > 0 && videoargs[1] == 'video'
      videoargs[2]
  end
  
end