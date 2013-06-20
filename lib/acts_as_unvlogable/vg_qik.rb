# ----------------------------------------------
#  Class for Qik (qik.com)
#  http://qik.com/video/340982
# ----------------------------------------------


class VgQik
  
  def initialize(url=nil, options={})
    @url = url
    @video_id = parse_url(url)
    h = {"Content-Type" => "application/json"}
    @page = Net::HTTP.start("engine.qik.com", "80") do |connection|
      JSON.parse(connection.post("/api/jsonrpc?apikey=e53d41680124e6d0", {:method => "qik.stream.public_info", :params => [340982]}.to_json, h).body)
    end
  end
  
  def title
    @page[0]['title']
  end
  
  def thumbnail
    @page[0]['large_thumbnail_url']
  end
  
  def embed_url
    "http://qik.com/swfs/qikPlayer5.swf?streamID=#{@page[0]['embed_html'].split("streamID=")[1].split("&")[0]}&amp;autoplay=false"
  end

  def embed_html(width=425, height=344, options={}, params={})
    @page[0]['embed_html']
  end
  
  def flv
    "http://media.qik.com/vod/flvs-play?assetId=#{@page[0]['embed_html'].split("streamID=")[1].split("&")[0]}&profile=flvs-normal"
  end

  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Qik"
  end

  protected
  
  def parse_url(url)
    video_id = nil
    if url.split('#').size > 1
      pieces = url.split(/#|=/)
      hash = Hash[*pieces]
      video_id = hash['v']
    else
      video_id = url.split("/")[4]
    end
    video_id
  end
  
end