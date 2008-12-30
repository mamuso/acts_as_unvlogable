# ----------------------------------------------
# 
# 
# 
# 
# ----------------------------------------------


class VgGoogle
  
  def initialize(url=nil)
  end
  
  def title
  end
  
  def thumbnail
  end
  
  def embed_url
  end

  def embed_html(width=425, height=344, options={})
  end
  
  def flv
  end
  
  private
  
  def parse_url(url)
      uri = URI.parse(url)
      args = uri.query
      video_id = ''
      if args and args.split('&').size <= 1
        args.split('&').each do |arg|
          k,v = arg.split('=')
          video_id = v.to_i and break if k == 'docid'
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