# ----------------------------------------------
#  Class for 11870 (11870.com)
#  http://11870.com/pro/chic-basic-born/media/b606abfe
# ----------------------------------------------


class Vg11870
  
  def initialize(url=nil, options={})
    @url = url
    @page = Hpricot(open(url))
    @flashvars = get_hash(@page.to_s.split("var flashvars = {")[1].split("};")[0]).delete_if {|key, value| key == "displaywidth" }
    @flashvars['logo'] = "http://11870.com#{@flashvars['logo']}" unless @flashvars['logo'].blank?
  end
  
  def title
    CGI::unescapeHTML @page.search("//h1[@class='fn name']/a").first.inner_html
  end
  
  def thumbnail
    @flashvars['image']
  end
  
  def embed_url
    query = @flashvars.map {|k,v| "&#{k}=#{v}"}
    "http://11870.com/multimedia/flvplayer.swf?#{query}"
  end

  def embed_html(width=425, height=344, options={})
    "<object width='#{width}' height='#{height}' classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0'> <param name='movie' value='#{embed_url}' /> <param name='quality' value='high' /><embed src='#{embed_url}' width='#{width}' height='#{height}' quality='high' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer'/></object>"
  end
  
  def flv
    @flashvars['file']
  end
  
  protected
  
  def get_hash(string)
    hash = Hash.new
    string.split(",").each do |elemement|
      pieces = elemement.split(': "')
      hash[pieces[0]] = "#{pieces[1]}".gsub('"', '').to_s
    end
    hash.delete_if { |key, value| value.nil? }
  end
  
end