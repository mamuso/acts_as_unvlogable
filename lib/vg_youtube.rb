# ----------------------------------------------
#  Class for Youtube (youtube.com)
#  http://www.youtube.com/watch?v=25AsfkriHQc
# ----------------------------------------------


class VgYoutube
  
  def initialize(url=nil, options={})
    object = YouTubeG::Client.new rescue {}
    @url = url
    @video_id = parse_url(url)
    @details = object.video_by(@video_id)
    raise if @details.blank?
  end
  
  def title
    @details.title
  end
  
  def thumbnail
    @details.thumbnails.first.url
  end
  
  def embed_url
    @details.media_content.first.url if @details.noembed == false
  end
  
  # options 
  #   :nosearchbox => true | removes the searchbox on the player
  # 
  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}'><param name='movie' value='#{embed_url}&fs=1#{'&searchbox=0' if options[:nosearchbox]}'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='#{embed_url}&fs=1#{'&searchbox=0' if options[:nosearchbox] == true}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='#{width}' height='#{height}'></embed></object>" if @details.noembed == false
  end
  
  
  def flv
    doc = URI::parse(@url).read
    t = doc.split("&t=")[1].split("&")[0]
    "http://www.youtube.com/get_video.php?video_id=#{@video_id}&t=#{t}"
  end
  
  private
  
  def parse_url(url)
    uri = URI.parse(url)
    args = uri.query
    video_id = ''
    if args and args.split('&').size >= 1
      args.split('&').each do |arg|
        k,v = arg.split('=')
        video_id = v and break if k == 'v'
      end
      raise unless video_id
    else
      raise
    end
    video_id
  rescue
    nil    
  end
  
end