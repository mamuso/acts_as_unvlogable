# ----------------------------------------------
#  Class for Google Video (video.google.com)
#  http://video.google.com/videoplay?docid=4798198171297333202&ei=Vq9aSeOmBYuGjQK-6Zy5CQ&q=pocoyo&hl=es
# ----------------------------------------------


class VgGoogle
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://video.google.com/videofeed?fgvns=1&fai=1&docid=#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//item/title")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//media:thumbnail").attributes['url']
  end
  
  def embed_url
    "http://video.google.com/googleplayer.swf?docid=#{@video_id}&fs=true"
  end

  def embed_html(width=425, height=344, options={})
    "<embed id='VideoPlayback' src='#{embed_url}' style='width:#{width}px;height:#{height}px' allowFullScreen='true' allowScriptAccess='always' type='application/x-shockwave-flash'> </embed>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//media:content[@type='video/x-flv']").attributes['url']
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      (CGI::parse(uri.query)['docid'] if uri.query) || nil
  end
  
end