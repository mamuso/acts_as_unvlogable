# ----------------------------------------------
#  Class for Myspace (vids.myspace.com)
#  http://vids.myspace.com/index.cfm?fuseaction=vids.individual&VideoID=27111431
# ----------------------------------------------


class VgMyspace
  
  def initialize(url=nil, options={})
    @url = url
    @page = Nokogiri::HTML(open(@url))
  end
  
  def title
    @page.xpath("//meta[@property='og:title']").first["content"].split("Video by")[0].strip
  end
  
  def thumbnail
    @page.xpath("//meta[@property='og:image']").first["content"].strip
  end
  
  def duration
    nil
  end
  
  def embed_url
    @page.xpath("//meta[@name='twitter:player']").first["content"].strip
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe width='#{width}' height='#{height}' src='#{embed_url}' frameborder='0' allowtransparency='true' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
  end
  
  def flv
    nil
  end

  def download_url
    nil
  end

  def service
    "Myspace"
  end

end