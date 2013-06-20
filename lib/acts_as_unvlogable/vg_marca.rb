# ----------------------------------------------
#  Class for Marca.tv (www.marca.tv)
#  http://www.marca.com/tv/?v=DN23wG8c1Rj
# ----------------------------------------------


class VgMarca
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = @url.query_param('v')
    res =  Net::HTTP.get(URI.parse("http://estaticos.marca.com/consolamultimedia/marcaTV/elementos/#{@video_id[0,1]}/#{@video_id[1,1]}/#{@video_id[2,100]}.xml"))
    @feed = REXML::Document.new(res)    
  end
  
  def title
    REXML::XPath.first( @feed, "//titulo" )[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first( @feed, "//foto" )[0].to_s
  end
  
  def duration
    nil
  end
  
  def embed_url
    "http://www.marca.com/componentes/flash/embed.swf?ba=0&cvol=1&bt=1&lg=1&vID=#{@video_id}&ba=1"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<embed width='#{width}' height='#{height}' wmode='transparent' pluginspage='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwave-flash' allowfullscreen='true' quality='high' src='#{embed_url}'/>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//media")[0].to_s
  end

  def download_url
    nil
  end

  def service
    "Marca.tv"
  end
  
end