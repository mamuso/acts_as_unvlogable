class UnvlogIt
  
  def initialize(url=nil, options={})
    raise ArgumentError.new("We need a video url") if url.blank?
    @object ||= "vg_#{get_domain(url).downcase}".camelize.constantize.new(url, options) rescue nil
            raise ArgumentError.new("Unsuported url or service") if @object.nil?
  end
  
  def title
    @object.title rescue nil
  end
  
  def thumbnail
    @object.thumbnail rescue nil
  end
  
  def embed_url
    @object.embed_url rescue nil
  end

  def embed_html(width=425, height=344, options={})
    @object.embed_html(width, height, options) rescue nil
  end
  
  def flv
    @object.flv rescue nil
  end
  
  def video_details
    {
      :title => @object.title,
      :thumbnail => @object.thumbnail,
      :embed_url => @object.embed_url,
      :embed_html => @object.embed_html,
      :flv => @object.flv
    }
  end
  
  private
  
  def get_domain(url)
    host = URI::parse(url).host.split(".")
    unless host.size == 1
      host[host.size-2]
    else
      host[0]
    end
  end
  
end