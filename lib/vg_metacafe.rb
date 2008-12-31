# ----------------------------------------------
#  Class for Metacafe (www.metacafe.com)
#  http://www.metacafe.com/watch/476621/experiments_with_the_myth_busters_with_diet_coke_and_mentos_dry/
# ----------------------------------------------


class VgMetacafe
  
  def initialize(url=nil)
    @url = url
    @args = parse_url(url)
  end
  
  def title
    @args[2].humanize unless @args[2].blank?
  end
  
  def thumbnail
    "http://www.metacafe.com/thumb/#{@args[1]}.jpg"
  end
  
  def embed_url
    "http://www.metacafe.com/fplayer/#{@args[1]}/#{@args[2]}.swf"
  end

  def embed_html(width=425, height=344, options={})
    "<embed src='http://www.metacafe.com/fplayer/#{@args[1]}/#{@args[2]}.swf' width='#{width}' height='#{height}' wmode='transparent' pluginspage='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwave-flash'></embed>"
  end
  
  def flv
    params = Hash.new
    open(self.embed_url) {|f|
      params = get_hash f.base_uri.request_uri.split("?")[1]
    }
    "#{CGI::unescape params['mediaURL']}?__gda__=#{params['gdaKey']}"
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
  
  def get_hash(string)
    hash = Hash.new
    string.split("&").each do |elemement|
      pieces = elemement.split("=")
      hash[pieces[0]] = pieces[1]
    end
    hash.delete_if { |key, value| value.nil? }
  end
  
  
end