# ----------------------------------------------
#  Class for Google Video (video.google.com)
# ----------------------------------------------


class VgGoogle
  
  def initialize(url=nil)
    @url = url
    @video_id = parse_url(url)
    res = Net::HTTP.get(URI.parse("http://video.google.com/videofeed?fgvns=1&fai=1&docid=#{@video_id}"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//item/title")[0]
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//media:thumbnail").attributes['url']
  end
  
  def embed_url
    "http://video.google.com/googleplayer.swf?docid=#{@video_id}&fs=true"
  end

  def embed_html(width=425, height=344, options={})
    "<embed id='VideoPlayback' src='http://video.google.com/googleplayer.swf?docid=#{@video_id}&fs=true' style='width:#{width}px;height:#{height}px' allowFullScreen='true' allowScriptAccess='always' type='application/x-shockwave-flash'> </embed>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//media:content[@type='video/x-flv']").attributes['url']
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      args = uri.query
      video_id = ''
      if args and args.split('&').size >= 1
        args.split('&').each do |arg|
          k,v = arg.split('=')
          video_id = v.to_i and break if k == 'docid'
        end
        raise unless video_id
      else
        raise
      end
      video_id
    rescue
      nil
  end
  
end