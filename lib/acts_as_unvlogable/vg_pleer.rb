class VgPleer
  attr_accessor :track_id
  
  def initialize(url, options={})
    url = url.sub(/pleer.com/, 'pleer.net') #addressing permanent redirection
    @uri = URI.parse(url)
    @track_id = @uri.path.match(/tracks\/([\w\d]+)/)[1]
    @url = url
    raise ArgumentError unless @track_id
  end
  
  def title
    @title ||= [pp_data[:singer], pp_data[:song]].join(' - ')
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object width=\"#{width}\" height=\"#{height}\"><param name=\"movie\" value=\"http://embed.pleer.com/track?id=#{track_id}\"></param><embed src=\"http://embed.pleer.com/track?id=#{track_id}\" type=\"application/x-shockwave-flash\" width=\"#{width}\" height=\"#{height}\"></embed></object>"
  end
  
  def service
    "Pleer"
  end
  
  private  
  def pp_data
    return @pp_data if defined? @pp_data
    page = Nokogiri::HTML(Net::HTTP.get(@uri))
    info = page.xpath('//li[@singer]').first
    @pp_data = {
      :singer =>    info['singer'],   # artist name
      :song =>      info['song'],     # song title
      :file_id =>   info['file_id'],  # wtf
      :link =>      info['link'],     # same as @track_id
      :duration =>  info['duration'], # duration of the song in seconds
      :size =>      info['size'],     # file size
      :rate =>      info['rate']      # bit rate
    }
  end
end
