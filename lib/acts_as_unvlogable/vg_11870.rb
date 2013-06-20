# ----------------------------------------------
#  Class for 11870 (11870.com)
#  http://11870.com/pro/chic-basic-born/media/b606abfe
# ----------------------------------------------


class Vg11870
  
  def initialize(url=nil, options={})
    @url = url
    @page = Hpricot(open(url))
    @flashvars = CGI::parse(@page.to_s.split("flashvars=&quot;")[1].split("&quot;")[0])
  end
  
  def title
    CGI::unescapeHTML @page.search("//h1[@class='fn name']/a").first.inner_html
  end
  
  def thumbnail
    @flashvars['image']
  end
  
  def duration
    nil
  end
  
  def embed_url
    query = @flashvars.map {|k,v| "&#{k}=#{v}"}
    "http://11870.com/multimedia/flvplayer.swf?#{query}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object width='#{width}' height='#{height}' classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0'> <param name='movie' value='#{embed_url}' /> <param name='quality' value='high' /><embed src='#{embed_url}' width='#{width}' height='#{height}' quality='high' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer'/></object>"
  end
  
  def flv
    @flashvars['file']
  end
 
  def download_url
    nil
  end
  
  def service
    "11870.com"
  end
  
end