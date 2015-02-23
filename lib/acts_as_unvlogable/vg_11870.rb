# ----------------------------------------------
#  Class for 11870 (11870.com)
#  http://11870.com/pro/chic-basic-born/media/b606abfe
# ----------------------------------------------


class Vg11870
  
  def initialize(url=nil, options={})
    @url = url.sub "http:", "https:"
    @page = Nokogiri::HTML(open(@url))
  end
  
  def title
    CGI::unescapeHTML @page.xpath("//span[@itemprop='name']").first.text.strip
  end
  
  def thumbnail
    @page.xpath("//img[@itemprop='image']").first["src"]
  end
  
  def duration
    nil
  end
  
  def embed_url
    "https://s3-eu-west-1.amazonaws.com/static.11870.com/11870/player.swf?netstreambasepath=#{@url}&id=video&file=#{flv}&image=#{thumbnail}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object width='#{width}' height='#{height}' classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0'> <param name='movie' value='#{embed_url}' /> <param name='quality' value='high' /><embed src='#{embed_url}' width='#{width}' height='#{height}' quality='high' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer'/></object>"
  end
  
  def flv
    @page.xpath("//div[@id='video']/span").first.text.strip
  end
 
  def download_url
    nil
  end
  
  def service
    "11870.com"
  end
  
end