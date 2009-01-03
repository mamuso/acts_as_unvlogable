# ----------------------------------------------
#  Class for dalealplay (dalealplay.com)
#  http://www.dalealplay.com/informaciondecontenido.php?con=80280
# 
# Crappy without api
# ----------------------------------------------


class VgDalealplay
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    @page = Hpricot(open(url))
  end
  
  def title
    (Iconv.iconv 'utf-8', 'iso-8859-1', @page.search("//title").inner_html.split(" - www.dalealplay.com")[0]).to_s
  end
  
  def thumbnail
    "http://images-00.dalealplay.com/contenidos2/#{@video_id}/captura.jpg"
  end
  
  def embed_url
    @page.search("//link[@rel='video_src']").first.attributes["href"].sub("autoStart=true", "autoStart=false")
  end

  def embed_html(width=425, height=344, options={})
    "<object type='application/x-shockwave-flash' width='#{width}' height='#{height}' data='#{embed_url}'><param name='quality' value='best' />	<param name='allowfullscreen' value='true' /><param name='scale' value='showAll' /><param name='movie' value='http#{embed_url}' /></object>"
  end
  
  def flv
    "http://videos.dalealplay.com/contenidos3/#{get_hash(URI::parse(embed_url).query)['file']}"
  end
  
  protected
  
  def parse_url(url)
      uri = URI.parse(url)
      args = uri.query
      video_id = ''
      if args && !url.index('informaciondecontenido').nil?
        args.split('&').each do |arg|
          k,v = arg.split('=')
          video_id = v and break if k == 'con'
        end
        raise unless video_id
      else
        raise
      end
      video_id
    rescue
      nil
  end
  
  def get_hash(string)
    hash = Hash.new
    string.split("&").each do |elemement|
      pieces = elemement.split("=")
      hash[pieces[0]] = pieces[1]
    end
    hash.delete_if { |key, value| value.nil? }
  end
  
end