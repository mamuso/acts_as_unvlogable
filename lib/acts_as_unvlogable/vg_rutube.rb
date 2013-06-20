class VgRutube

  def initialize(url=nil, options={})
    @url = url
    parse_url(url)
  end

  def title
    rt_info["movie"][0]["title"][0].strip
  end

  # this method of extraction is somewhat fragile to changes in RuTube urls
  # more correct way would be using rt_info structure, like it was done in title()
  def thumbnail
    # size=1 gives bigger thumbnail.
    # I'm not sure how to add size parameter in compatible way
    size = 2
    "http://img.rutube.ru/thumbs/#{movie_hash[0,2]}/#{movie_hash[2,2]}/#{movie_hash}-#{size}.jpg"
  end

  def embed_url
    # path to swf
    "http://video.rutube.ru/#{movie_hash}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    # overridden cause we have to change default size if needed
    return <<-"END"
    <object width="#{width}" height="#{height}"><param
      name="movie" value="#{embed_url}"></param><param
      name="wmode" value="window"></param><param
      name="allowFullScreen" value="true"></param><embed
      src="#{embed_url}" type="application/x-shockwave-flash"
      wmode="window" width="#{width}" height="#{height}"
      allowFullScreen="true"></embed>
    </object>
    END
  end

  def flv
    # Fragile, untested, issues one redirect to actual location
    # can't be extracted from rt_info
    "http://bl.rutube.ru/#{movie_hash}.iflv"
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

  private

  attr_accessor :movie_id
  RT_XML_API = "http://rutube.ru/cgi-bin/xmlapi.cgi"

  def movie_hash
    @movie_hash ||= rt_info["movie"][0]["playerLink"][0].match( %r{[a-f0-9]+$} )[0]
  end

  def rt_info
    url = RT_XML_API + "?rt_movie_id=#{movie_id}&rt_mode=movie"
    @rt_info ||= XmlSimple.xml_in( Net::HTTP.get_response( URI.parse(url) ).body )
  end

  def parse_url(url)
    uri = URI.parse(url)
    @movie_id = uri.path.match(/\d+/)[0]
    # this doesn't work reliably:
    # @movie_hash = uri.query.match(/(^|&)v=([^&]+)/)[2]
    # we'll cut it from rt_info instead
  end

end
