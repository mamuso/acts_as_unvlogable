# ----------------------------------------------
#  Class for Metacafe (www.metacafe.com)
#  http://www.metacafe.com/watch/476621/experiments_with_the_myth_busters_with_diet_coke_and_mentos_dry/
# ----------------------------------------------


class VgMetacafe
  
  def initialize(url=nil, options={})
    @url = url
    @args = parse_url(url)
    
    #is the video 'youtubed'?
    @youtubed = @args[1].index("yt-").nil? ? false : true
    @yt = @youtubed ? VgYoutube.new("http://www.youtube.com/watch?v=#{@args[1].sub('yt-', '')}") : nil
  end
  
  def title
    @youtubed ? @yt.title : (@args[2].humanize unless @args[2].blank?)
  end
  
  def thumbnail
    "http://www.metacafe.com/thumb/#{@args[1]}.jpg"
  end
  
  def embed_url
    "http://www.metacafe.com/fplayer/#{@args[1]}/#{@args[2]}.swf"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<embed src='#{embed_url}' width='#{width}' height='#{height}' wmode='transparent' pluginspage='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwave-flash'></embed>"
  end
  
  def flv
    if @youtubed
      @yt.flv
    else
      params = Hash.new
      open(self.embed_url) {|f|
        params = CGI::parse(f.base_uri.request_uri.split("?")[1])
      }
      CGI::unescape "#{ params['mediaURL']}?__gda__=#{params['gdaKey']}"
    end
  end

  def duration
    nil
  end

  def download_url
    nil
  end

  def service
    "Metacafe"
  end

  private
  
  def parse_url(url)
      uri = URI.parse(url)
      path = uri.path
      @args = ''
      if path and path.split("/").size >=1
        @args = path.split("/")
        @args.delete("watch")
        
        raise unless @args.size > 0
      else
        raise
      end
      @args
    rescue
      nil
  end
  
end