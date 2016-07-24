class VgGfycat
  attr_accessor :video_id
  
  def initialize(url, options={})
    @url = url
    @uri = URI.parse(url)
    @video_id = @uri.path.split("/")[-1]
    json_endpoint = "https://gfycat.com/cajax/get/#{@video_id}"
    @json = JSON.parse(Net::HTTP.get(URI.parse(json_endpoint)))
    raise ArgumentError unless @video_id or @json["error"]
  end
  
  def title
    @title ||= @json["gfyItem"]["title"]
  end

  def thumbnail
    @thumbnail ||= @json["gfyItem"]["posterUrl"]
  end

  def embed_url
    @embed_url ||= @json["gfyItem"]["mp4Url"]
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
    "Gfycat"
  end
end
