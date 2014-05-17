# ----------------------------------------------
#  Class for Youtube (youtube.com)
#  http://www.youtube.com/watch?v=MVa4q-YVjD8
# ----------------------------------------------

class VgYoutube
  
  def initialize(url=nil, options={})
    object = YouTubeIt::Client.new({})
    @url = url
    @video_id = @url.query_param('v')
    begin
      @details = object.video_by(@video_id)
      raise if @details.blank?
      @details.instance_variable_set(:@noembed, false) unless !@details.embeddable?
    rescue
      raise ArgumentError, "Unsuported url or service"
    end
  end
  
  def title
    @details.title
  end
  
  def thumbnail
    @details.thumbnails.first.url
  end
  
  def duration
    @details.duration
  end
  
  def embed_url
    @details.media_content.first.url if @details.noembed == false
  end
  
  # iframe embed — https://developers.google.com/youtube/player_parameters#Manual_IFrame_Embeds
  def embed_html(width=425, height=344, options={}, params={})
    "<iframe id='ytplayer' type='text/html' width='#{width}' height='#{height}' src='#{embed_url}#{options.map {|k,v| "&#{k}=#{v}"}}' frameborder='0'/>" if @details.noembed == false
  end
  
  def service
    "Youtube"
  end

end