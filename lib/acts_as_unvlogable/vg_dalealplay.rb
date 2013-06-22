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
    @page = open(url) {|f| Hpricot(f.read.encode("UTF-8")) }
  end
  
  def title
    @page.search("//title").inner_html.split(" - Vídeo Online")[0].to_s
  end
  
  def thumbnail
    "http://images-00.dalealplay.com/contenidos2/#{@video_id}/captura.jpg"
  end
  
  def embed_url
    @page.search("//link[@rel='video_src']").first.attributes["href"].sub("autoStart=true", "autoStart=false")
  end

  def duration
    nil
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object type='application/x-shockwave-flash' width='#{width}' height='#{height}' data='#{embed_url}'><param name='quality' value='best' />	<param name='allowfullscreen' value='true' /><param name='scale' value='showAll' /><param name='movie' value='http#{embed_url}' /></object>"
  end
  
  def flv
    "http://videos.dalealplay.com/contenidos3/#{CGI::parse(URI::parse(embed_url).query)['file']}"
  end

  def download_url
    nil
  end

  def service
    "dalealplay"
  end
  
end