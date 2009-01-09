# ----------------------------------------------
#  Class for Ted Talks (www.ted.com/talks)
#  http://www.ted.com/index.php/talks/benjamin_wallace_on_the_price_of_happiness.html
# ----------------------------------------------


class VgTed
  
  def initialize(url=nil, options={})
    @url = url
    raise unless URI::parse(url).path.split("/").include? "talks"
    @page = Hpricot(open(url))
    embedder = @page.to_s.split("new SWFObject")[1].split("so.addParam")[0].gsub("\n", "").gsub("\t", "").split("so.addVariable(\"")
    embedder.shift
    emb =embedder.map {|k| 
      i = k.split("\",\"")
      "&#{i[0]}=#{i[1].gsub('");', '')}"
    }.join
    emb = "#{url}?#{emb.gsub(" ", "")}"
    @flashvars = "vu=http://video.ted.com/talks/embed/#{emb.query_param('hs').split("/")[-1].split("-stream-")[0]}-embed#{"-PARTNER" unless emb.query_param('hs').index("PARTNER").nil?}_high.flv&su=http://images.ted.com/images/ted/tedindex/embed-posters/#{emb.query_param('hs').split("/")[-1].split("-stream-")[0].gsub("_", "-")}.embed_thumbnail.jpg"
    @args = CGI::parse(@flashvars)
  end
  
  def title
    @page.search("//h1/span").first.inner_html.strip
  end
  
  def thumbnail
    "#{@args['su']}"
  end
  
  def embed_url
      "http://video.ted.com/assets/player/swf/EmbedPlayer.swf?#{@flashvars}"
  end

  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}'></param><param name='allowFullScreen' value='true' /><param name='wmode' value='transparent'></param><param name='bgColor' value='#ffffff'></param><embed src='#{embed_url}' pluginspace='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwave-flash' wmode='transparent' bgColor='#ffffff'  width='#{width}' height='#{height}' allowFullScreen='true'></embed></object>"
  end
  
  def flv
    "#{@args['vu'].to_s}"
  end
  
end