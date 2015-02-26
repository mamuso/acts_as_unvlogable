# ----------------------------------------------
#  Class for Ted Talks (www.ted.com/talks)
#  http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html
# ----------------------------------------------


class VgTed
  
  def initialize(url=nil, options={})
    @url = url
    raise ArgumentError.new("Unsuported url or service") unless URI::parse(url).path.split("/").include? "talks"
    @page = Nokogiri::HTML(open(@url))
  end
  
  def title
    @page.xpath("//meta[@property='og:title']").first["content"].strip
  end
  
  def thumbnail
    @page.xpath("//meta[@property='og:image']").first["content"].strip
  end
  
  def duration
    nil
  end
  
  def embed_url
    @page.xpath("//link[@itemprop='embedURL']").first["href"].strip
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe src='#{embed_url}' width='#{width}' height='#{height}' frameborder='0' scrolling='no' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>"
  end
  
  def download_url
    nil
  end

  def service
    "Ted Talks"
  end

end