# ----------------------------------------------
#  Class for BlipTv (blip.tv)
#  http://blip.tv/file/678407/
# ----------------------------------------------


# class VgBlip
  
#   def initialize(url=nil, options={})
#     @url = url.split("?").first if url
#     res = Net::HTTP.get(URI.parse("#{url}?skin=rss"))
#     @feed = REXML::Document.new(res)
#   end
  
#   def title
#     CGI::unescape REXML::XPath.first(@feed, "//media:title")[0].to_s
#   end
  
#   def thumbnail
#     REXML::XPath.first(@feed, "//media:thumbnail").attributes['url']
#   end
  
#   def duration
#     nil
#   end
  
#   def embed_url
#     emb = REXML::XPath.first(@feed, "//blip:embedUrl")[0].to_s
#   end

#   def embed_html(width=425, height=344, options={}, params={})
#     "<iframe src='#{embed_url}.x?p=1' width='#{width}' height='#{height}' frameborder='0' allowfullscreen></iframe>"
#   end
  
#   def download_url
#     nil
#   end

#   def service
#     "Blip.tv"
#   end

# end