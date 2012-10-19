require "acts_as_unvlogable/vg_youtube"

class VgYoutu < VgYoutube
  def initialize(url=nil, options={})
    url = URI(url)
    url.host = 'www.youtube.com'
    url.query = "#{url.query}&v=#{url.path[1..-1]}"
    url.path = '/watch'
    super(url.to_s, options)
  end
end
