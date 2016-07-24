class VgVine
  attr_accessor :video_id
  
  def initialize(url, options={})
    @url = url
    @uri = URI.parse(url)
    @video_id = @uri.path.match(/v\/([\w\d]+)/)[1]
    json_endpoint = "https://vine.co/oembed/#{@video_id}.json"
    @json = JSON.parse(Net::HTTP.get(URI.parse(json_endpoint)))
    raise ArgumentError unless @video_id
  end
  
  def title
    @title ||= @json["title"]
  end

  def thumbnail
    @thumbnail ||= @json["thumbnail_url"]
  end

  def embed_url
    @embed_url = "#{@url}/embed/simple"
  end

  def embed_html(width=600, height=600, options={}, params={})
    "<iframe id='ytplayer' type='text/html' width='#{width}' height='#{height}' src='#{@embed_url}' frameborder='0'/><script src='https://platform.vine.co/static/scripts/embed.js'></script>"
  end

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Vine"
  end
end
