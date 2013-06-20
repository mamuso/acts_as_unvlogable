# ----------------------------------------------
#  Class for Youtube (youtube.com)
#  http://www.youtube.com/watch?v=25AsfkriHQc
# ----------------------------------------------


class VgYoutube
  
  def initialize(url=nil, options={})
    object = YouTubeIt::Client.new({})
    @url = url
    @video_id = @url.query_param('v')
    @details = object.video_by(@video_id)
    @details.instance_variable_set(:@noembed, false)
    raise if @details.blank?
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
  
  # options 
  #   You can read more about the youtube player options in 
  #   http://code.google.com/intl/en/apis/youtube/player_parameters.html
  #   Use them in options (ex {:rel => 0, :color1 => '0x333333'})
  # 
  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}#{options.map {|k,v| "&#{k}=#{v}"}.join}'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='#{embed_url}#{options.map {|k,v| "&#{k}=#{v}"}.join}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='#{width}' height='#{height}'></embed></object>" if @details.noembed == false
  end
  
  
  def flv
    doc = URI::parse("http://www.youtube.com/get_video_info?&video_id=#{@video_id}").read
    CGI::unescape(doc.split("&url_encoded_fmt_stream_map=")[1]).split("url=").each do |u|
    	u = CGI::unescape(u)
    	unless u.index("x-flv").nil?
    		return u.split("&quality").first
    		break
    	end
    end
  end
  
  def download_url
    flv
  end

  def service
    "Youtube"
  end

end