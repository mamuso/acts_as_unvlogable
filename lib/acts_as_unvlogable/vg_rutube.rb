class VgRutube

  def initialize(url=nil, options={})
    @url = url
    @page = Nokogiri::HTML(open(@url)) rescue nil
    raise ArgumentError.new("Unsuported url or service") if @page.xpath("//meta[@property='og:video:iframe']").blank?
  end

  def title
    @page.xpath("//meta[@property='og:title']").first["content"].strip
  end
  def thumbnail
    @page.xpath("//meta[@property='og:image']").first["content"].strip
  end

  def embed_url
    @page.xpath("//meta[@property='og:video:iframe']").first["content"].strip
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<iframe width='#{width}' height='#{height}' src='#{embed_url}' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>"
  end

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Rutube"
  end

end
