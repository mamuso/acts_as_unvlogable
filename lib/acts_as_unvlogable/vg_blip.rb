# ----------------------------------------------
#  Class for BlipTv (blip.tv)
#  http://blip.tv/file/678407/
# ----------------------------------------------


class VgBlip
  
  def initialize(url=nil, options={})
    @url = url.split("?").first if url
    res = Net::HTTP.get(URI.parse("#{url}?skin=rss"))
    @feed = REXML::Document.new(res)
  end
  
  def title
    CGI::unescape REXML::XPath.first(@feed, "//media:title")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//blip:smallThumbnail")[0].to_s
  end
  
  def duration
    nil
  end
  
  def embed_url
    emb = REXML::XPath.first(@feed, "//media:player")[0].to_s
    emb.split("src=\"")[1].split("\"")[0]
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<embed src='#{embed_url}' type='application/x-shockwave-flash' width='#{width}' height='#{height}' allowscriptaccess='always' allowfullscreen='true'></embed>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//enclosure").attributes['url']
  end

  def download_url
    nil
  end

  def service
    "Blip.tv"
  end

end