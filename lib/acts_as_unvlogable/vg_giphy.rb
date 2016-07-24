class VgGiphy
  attr_accessor :video_id
  
  def initialize(url, options={})
    @url = url
    @uri = URI.parse(url)
    @video_id = @uri.path.match(/gifs\/([\w\-\d]+)/)[1].split("-")[-1]
    json_endpoint = "http://api.giphy.com/v1/gifs?api_key=dc6zaTOxFJmzC&ids=#{@video_id}"
    @json = JSON.parse(Net::HTTP.get(URI.parse(json_endpoint)))
    raise ArgumentError unless @video_id
  end
  
  def title
    nil
  end

  def thumbnail
    @thumbnail ||= @json["data"][0]["images"]["fixed_height_still"]["url"]
  end

  def embed_url
    @embed_url = @json["data"][0]["images"]["looping"]["mp4"]
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<video id='giphyplayer' width='#{width}' height='#{height}' controls autoplay><source src='#{@embed_url}' type='video/mp4'>Your browser does not support mp4.</video>"
  end

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Giphy"
  end
end
