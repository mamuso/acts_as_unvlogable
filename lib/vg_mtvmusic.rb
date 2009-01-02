# ----------------------------------------------
#  Class for MTV Music (www.mtvmusic.com)
#  http://www.mtvmusic.com/astley_rick/videos/55086/never_gonna_give_you_up.jhtml
#  
#  
#  quite ugly, we know :(
# ----------------------------------------------


class VgMtvmusic
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    @feed = nil

    # veeeeeery ugly
    page = Hpricot(open(url))
    searchterms = page.search("//title").first.inner_html.split("-")
    res =  Net::HTTP.get(URI.parse("http://api.mtvnservices.com/1/video/search/?term=#{searchterms[1].gsub(' ', '%20')}#{searchterms[2].gsub(' ', '%20')}"))
    search = REXML::Document.new(res)
    entries = search.elements.to_a("//entry")
    entries.each do |entry|
      if REXML::XPath.first(entry, "media:content" ).attributes['url'] == "http://media.mtvnservices.com/mgid:uma:video:api.mtvnservices.com:#{@video_id}"
        @feed = entry
      end
    end
  end
  
  def title
    REXML::XPath.first(@feed, "//entry/title")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//media:thumbnail").attributes['url']
  end
  
  def embed_url
    REXML::XPath.first(@feed, "//media:content[@type='application/x-shockwave-flash']").attributes['url']
  end

  def embed_html(width=425, height=344, options={})
    "<embed src='#{embed_url}' width='#{width}' height='#{height}' type='application/x-shockwave-flash' flashVars='dist=http://www.mtvmusic.com' allowFullScreen='true' AllowScriptAccess='never'></embed>"
  end
  
  # this method fails depending on country restrictions
  def flv
    res =  Net::HTTP.get(URI.parse("http://api-media.mtvnservices.com/player/embed/includes/mediaGen.jhtml?uri=mgid:uma:video:api.mtvnservices.com:#{@video_id}&vid=#{@video_id}&ref=#{CGI::escape "{ref}"}"))
    search = REXML::Document.new(res)
    REXML::XPath.first(search, "//rendition/src")[0]
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      args = uri.query
      video_id = nil
      if args and args.split('&').size >= 1
        args.split('&').each do |arg|
          k,v = arg.split('=')
          video_id = v and break if k == 'id'
        end
      else
        video_id = URI::parse(url).path.split("/")[3]
      end
      raise if video_id.nil?
      video_id
    rescue
      nil
  end
  
end