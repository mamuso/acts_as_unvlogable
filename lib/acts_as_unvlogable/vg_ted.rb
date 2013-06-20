# ----------------------------------------------
#  Class for Ted Talks (www.ted.com/talks)
#  http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html
# ----------------------------------------------


class VgTed
  
  def initialize(url=nil, options={})
    @url = url
    raise unless URI::parse(url).path.split("/").include? "talks"
    @page = Hpricot(open(url))
    id = @page.to_s.split("ted id=")[1].split("\]")[0]
    @emb = Hpricot(open("http://www.ted.com/talks/embed/id/#{id}"))
    @flashvars = CGI::unescapeHTML(@emb.to_s).split("param name=\"flashvars\" value=\"")[1].split("\"")[0]
    @args = CGI::parse(@flashvars)
  end
  
  def title
    @page.search("//h1/span").first.inner_html.strip
  end
  
  def thumbnail
    "#{@args['su']}"
  end
  
  def duration
    nil
  end
  
  def embed_url
      "http://video.ted.com/assets/player/swf/EmbedPlayer.swf?#{@flashvars}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}'></param><param name='allowFullScreen' value='true' /><param name='wmode' value='transparent'></param><param name='bgColor' value='#ffffff'></param><embed src='#{embed_url}' pluginspace='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwave-flash' wmode='transparent' bgColor='#ffffff'  width='#{width}' height='#{height}' allowFullScreen='true'></embed></object>"
  end
  
  def flv
    "#{@args['vu'].to_s}"
  end
  
  def download_url
    nil
  end

  def service
    "Ted Talks"
  end

end