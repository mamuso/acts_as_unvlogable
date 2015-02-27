# ----------------------------------------------
#  Class for Flickr (flickr.com)
#  http://www.flickr.com/photos/andina/3158762127/in/photostream/
# ----------------------------------------------


class VgFlickr
  
  def initialize(url=nil, options={})
    # general settings
    @url = url
    @video_id = parse_url(url)
    settings ||= YAML.load_file(RAILS_ROOT + '/config/unvlogable.yml') rescue {}
    @details = Flickr::Photo.new(@video_id, options.nil? || options[:key].nil? ? settings['flickr_key'] : options[:key])
    raise if @details.media != "video"
  end
  
  def title
    @details.title
  end
  
  def thumbnail
    @details.source('Small')
  end
  
  def embed_url
    "http://www.flickr.com/apps/video/stewart.swf?v=63881&intl_lang=en-us&photo_secret=#{@details.secret}&photo_id=#{@video_id}"
  end

  def embed_html(width=425, height=344, options={}, params={})
    "<object type='application/x-shockwave-flash' width='#{width}' height='#{height}' data='http://www.flickr.com/apps/video/stewart.swf?v=63881' classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000'><param name='movie' value='#{embed_url}'></param> <param name='bgcolor' value='#000000'></param> <param name='allowFullScreen' value='true'></param><embed type='application/x-shockwave-flash' src='#{embed_url}' bgcolor='#000000' allowfullscreen='true' width='#{width}' height='#{height}'></embed></object>"
  end
  
  def download_url
    nil
  end

  def duration
    nil
  end

  def service
    "Flickr"
  end
  
  private
  
  def parse_url(url)
    video_id = URI::parse(url).path.split("/")[3]
    raise unless video_id
    video_id
  rescue
    nil    
  end
  
end