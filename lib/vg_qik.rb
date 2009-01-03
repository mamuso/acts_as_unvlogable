# ----------------------------------------------
#  Class for Qik (qik.com)
#  http://qik.com/video/340982
# ----------------------------------------------


class VgQik
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    @page = Hpricot(open("http://qik.com/video/#{@video_id}"))
    emb = @page.search('//input[@value^="<object"]').first.attributes['value']
    tx = Hpricot(emb)
    @feed_url =  get_hash(tx.search('//embed').first.attributes['flashvars'].to_s)["rssURL"]
    res =  Net::HTTP.get(URI.parse(@feed_url))
    @feed = REXML::Document.new(res)
  end
  
  def title
    REXML::XPath.first(@feed, "//item/title")[0].to_s
  end
  
  def thumbnail
    REXML::XPath.first(@feed, "//item/media:thumbnail").attributes['url']
  end
  
  def embed_url
    "http://qik.com/swfs/qikPlayer4.swf?rssURL=#{@feed_url}&autoPlay=false"
  end

  def embed_html(width=425, height=344, options={})
    "<object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0' width='#{width}' height='#{height}' id='qikPlayer' align='middle'><param name='allowScriptAccess' value='sameDomain' /><param name='allowFullScreen' value='true' /><param name='movie' value='#{embed_url}' /><param name='quality' value='high' /><param name='bgcolor' value='#333333' /><embed src='#{embed_url}' quality='high' bgcolor='#333333' width='#{width}' height='#{height}' name='qikPlayer' align='middle' allowScriptAccess='sameDomain' allowFullScreen='true' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer'/></object>"
  end
  
  def flv
    REXML::XPath.first(@feed, "//item/media:content[@type='video/x-flv']").attributes['url']
  end
  
  protected
  
  def parse_url(url)
    video_id = ''
    if url.split('#').size > 1
      url.split('#').each do |arg|
        k,v = arg.split('=')
        video_id = v and break if k == 'v'
      end
    else
      video_id = url.split("/")[4]
    end
    raise unless video_id
    video_id
    rescue
      nil
  end
  
  
  def get_hash(string)
    hash = Hash.new
    string.split("&").each do |elemement|
      pieces = elemement.split('=')
      hash[pieces[0]] = "#{pieces[1]}"
    end
    hash.delete_if { |key, value| value.nil? }
  end
  
  
end