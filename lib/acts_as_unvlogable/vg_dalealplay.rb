# encoding: utf-8
# ----------------------------------------------
#  Class for dalealplay (dalealplay.com)
#  http://www.dalealplay.com/informaciondecontenido.php?con=80280
# 
# Crappy without api
# ----------------------------------------------


class VgDalealplay
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = @url.query_param('con')
    @page = Nokogiri::HTML(open(@url))
  end
  
  def title
    @page.xpath("//title").first.text.split(" - Video Online")[0].to_s
  end
  
  def thumbnail
    @page.xpath("//meta[@itemprop='image']").first["content"]
  end
  
  def embed_url
    @page.xpath("//meta[@itemprop='embedUrl']").first["content"]
  end

  def duration
    nil
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe frameborder='0' marginwidth='0' marginheight ='0' id='videodap' scrolling='no' width='#{width}' height='#{height}' src='#{embed_url}'></iframe>"
  end
  
  def flv
    @page.xpath("//meta[@itemprop='contentUrl']").first["content"]
  end

  def download_url
    nil
  end

  def service
    "dalealplay"
  end
  
end