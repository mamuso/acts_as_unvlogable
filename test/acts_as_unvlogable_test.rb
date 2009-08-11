require 'test/unit'
require 'rubygems'
require 'shoulda'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
# Main class
require 'acts_as_unvlogable'
# Gems & other herbs
require 'open-uri'
require 'hpricot'



class ActsAsUnvlogableTest < Test::Unit::TestCase
  
  context "Instancing UnvlogIt" do
    
    context "without any url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "We need a video url") { UnvlogIt.new }
      end
    end
    
    context "with an unsupported url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://iwannagothere.net/") }
      end
    end
    
# ----------------------------------------------------------
#   Testing youtube
# ----------------------------------------------------------
    context "with an existent youtube url" do
      setup do
        @videotron = UnvlogIt.new("http://www.youtube.com/watch?v=muLIPWjks_M") # => Ninja cat comes closer while not moving!
      end
      should "initialize a VgYoutube instance" do
        assert_equal VgYoutube, @videotron.instance_values['object'].class
        assert_equal "http://www.youtube.com/watch?v=muLIPWjks_M", @videotron.instance_values['object'].instance_values['url']
        assert_equal "muLIPWjks_M", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Ninja cat comes closer while not moving!", :service => "Youtube"})
      end
    end


    context "with an existent youtube url that can not be embedded" do
        should "raise an ArgumentError" do
          assert_raise(ArgumentError, "Embedding disabled by request") { UnvlogIt.new("http://www.youtube.com/watch?v=3Oec8RuwVVs") }# => The Killers - Read My Mind 
        end
    end
    
    context "with an inexistent youtube url" do
      should "raise an ArgumentError" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.youtube.com/watch?v=inexistente") }
      end
    end



# ----------------------------------------------------------
#   Testing google video
# ----------------------------------------------------------
    context "with an existent google video url" do
      setup do
        @videotron = UnvlogIt.new("http://video.google.com/videoplay?docid=4798198171297333202&ei=Vq9aSeOmBYuGjQK-6Zy5CQ") # => Pocoyo. Musica Maestro
      end
      should "initialize a VgGoogle instance" do
        assert_equal VgGoogle, @videotron.instance_values['object'].class
        assert_equal "http://video.google.com/videoplay?docid=4798198171297333202&ei=Vq9aSeOmBYuGjQK-6Zy5CQ", @videotron.instance_values['object'].instance_values['url']
        assert_equal "4798198171297333202", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Pocoyo. Musica Maestro", :service => "Google Video"})
      end
    end
    
    context "with an invalid google video url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.google.es/search?q=wadus") }
      end
    end


# ----------------------------------------------------------
#   Testing metacafe
# ----------------------------------------------------------
    context "with an existent metacafe url" do
      setup do
        @videotron = UnvlogIt.new("http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/") # => Close Call! A320 Caught in Crosswinds 
      end
      should "initialize a VgMetacafe instance" do
        assert_equal VgMetacafe, @videotron.instance_values['object'].class
        assert_equal "http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/", @videotron.instance_values['object'].instance_values['url']
        assert_equal 3, @videotron.instance_values['object'].instance_values['args'].size
        assert !@videotron.instance_values['object'].instance_values['youtubed']
        assert_nil @videotron.instance_values['object'].instance_values['yt']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Close call a320 caught in crosswinds", :service => "Metacafe"})
      end
    end
    
    context "with an existent 'youtubed' metacafe url" do
      setup do
        @videotron = UnvlogIt.new("http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/") # => Close Call! A320 Caught in Crosswinds 
      end
      should "initialize a VgMetacafe instance" do
        assert_equal VgMetacafe, @videotron.instance_values['object'].class
        assert_equal "http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/", @videotron.instance_values['object'].instance_values['url']
        assert_equal 3, @videotron.instance_values['object'].instance_values['args'].size
        assert @videotron.instance_values['object'].instance_values['youtubed']
        assert VgYoutube, @videotron.instance_values['object'].instance_values['yt'].class
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Pop Rocks and Coke Myth", :service => "Metacafe"})
      end
    end
    
    
  end


# ----------------------------------------------------------
#   Testing dailymotion
# ----------------------------------------------------------
    context "with a dailymotion video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.dailymotion.com/video/x7u5kn_parkour-dayyy_sport") # => parkour dayyy
      end
      should "initialize a VgDailymotion instance" do
        assert_equal VgDailymotion, @videotron.instance_values['object'].class
        assert_equal "http://www.dailymotion.com/video/x7u5kn_parkour-dayyy_sport", @videotron.instance_values['object'].instance_values['url']
        assert_equal "x7u5kn_parkour-dayyy_sport", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "parkour dayyy", :service => "Dailymotion"})
      end
    end



# ----------------------------------------------------------
#   Testing collegehumor
# ----------------------------------------------------------
    context "with a collegehumor video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.collegehumor.com/video:1781938") # => Brohemian Rhapsody
      end
      should "initialize a VgCollegehumor instance" do
        assert_equal VgCollegehumor, @videotron.instance_values['object'].class
        assert_equal "http://www.collegehumor.com/video:1781938", @videotron.instance_values['object'].instance_values['url']
        assert_equal "1781938", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Brohemian Rhapsody", :service => "CollegeHumor"})
      end
    end


# ----------------------------------------------------------
#   Testing blip.tv
# ----------------------------------------------------------
    context "with a blip.tv video url" do
      setup do
        @videotron = UnvlogIt.new("http://blip.tv/file/678407/") # => Toy Break 26 : Adult Toys
      end
      should "initialize a VgBlip instance" do
        assert_equal VgBlip, @videotron.instance_values['object'].class
        assert_equal "http://blip.tv/file/678407/", @videotron.instance_values['object'].instance_values['url']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Toy Break 26 : Adult Toys", :service => "Blip.tv"})
      end
    end


# ----------------------------------------------------------
#   Testing mtvmusic.com
# ----------------------------------------------------------
    context "with a mtvmusic.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.mtvmusic.com/astley_rick/videos/55086/never_gonna_give_you_up.jhtml") # => Never Gonna Give You Up
      end
      should "initialize a VgMtvmusic instance" do
        assert_equal VgMtvmusic, @videotron.instance_values['object'].class
        assert_equal "http://www.mtvmusic.com/astley_rick/videos/55086/never_gonna_give_you_up.jhtml", @videotron.instance_values['object'].instance_values['url']
        assert_equal "55086", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Never Gonna Give You Up", :service => "MTV Music"})
      end
    end



# ----------------------------------------------------------
#   Testing vids.myspace.com
# ----------------------------------------------------------
    context "with a vids.myspace.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://vids.myspace.com/index.cfm?fuseaction=vids.individual&VideoID=27111431") # => rocabilis
      end
      should "initialize a VgMyspace instance" do
        assert_equal VgMyspace, @videotron.instance_values['object'].class
        assert_equal "http://vids.myspace.com/index.cfm?fuseaction=vids.individual&VideoID=27111431", @videotron.instance_values['object'].instance_values['url']
        assert_equal "27111431", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "rocabilis", :service => "Myspace"})
      end
    end


# ----------------------------------------------------------
#   Testing 11870.com
# ----------------------------------------------------------
    context "with an 11870.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://11870.com/pro/chic-basic-born/media/b606abfe") # => Chic & Basic Born
      end
      should "initialize a Vg11870 instance" do
        assert_equal Vg11870, @videotron.instance_values['object'].class
        assert_equal "http://11870.com/pro/chic-basic-born/media/b606abfe", @videotron.instance_values['object'].instance_values['url']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
        assert_not_nil @videotron.instance_values['object'].instance_values['flashvars']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Chic & Basic Born", :service => "11870.com"})
      end
    end


# ----------------------------------------------------------
#   Testing dalealplay.com
# ----------------------------------------------------------
    context "with a dalealplay.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.dalealplay.com/informaciondecontenido.php?con=80280") # => Camelos Semos  Jonathan  Tú si que vales
      end
      should "initialize a VgDalealplay instance" do
        assert_equal VgDalealplay, @videotron.instance_values['object'].class
        assert_equal "http://www.dalealplay.com/informaciondecontenido.php?con=80280", @videotron.instance_values['object'].instance_values['url']
        assert_equal "80280", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Camelos Semos  Jonathan  Tú si que vales ", :service => "dalealplay"}) 
      end
    end



# ----------------------------------------------------------
#   Testing flickr.com
# ----------------------------------------------------------
    context "with a flickr.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.flickr.com/photos/andina/3158687163/in/photostream/", {:key => "065b2eff5e604e2a408c01af1f27a982" }) # => Visto en la Tate Modern
      end
      should "initialize a VgFlickr instance" do
        assert_equal VgFlickr, @videotron.instance_values['object'].class
        assert_equal "http://www.flickr.com/photos/andina/3158687163/in/photostream/", @videotron.instance_values['object'].instance_values['url']
        assert_equal "3158687163", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Visto en la Tate Modern", :service => "Flickr"})
      end
    end


# ----------------------------------------------------------
#   Testing qik.com
# ----------------------------------------------------------
    context "with a qik.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://qik.com/video/340982") # => Honolulu Day 8: USS Arizona at Pearl Harbor
      end
      should "initialize a VgQik instance" do
        assert_equal VgQik, @videotron.instance_values['object'].class
        assert_equal "http://qik.com/video/340982", @videotron.instance_values['object'].instance_values['url']
        assert_equal "340982", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed_url']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Honolulu Day 8: USS Arizona at Pearl Harbor", :service => "Qik"})
      end
    end



# ----------------------------------------------------------
#   Testing www.marca.tv
# ----------------------------------------------------------
    context "with a www.marca.tv video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.marca.com/tv/?v=DN23wG8c1Rj") # => Pau entra por la puerta grande en el club de los 10.000
      end
      should "initialize a VgMarca instance" do
        assert_equal VgMarca, @videotron.instance_values['object'].class
        assert_equal "http://www.marca.com/tv/?v=DN23wG8c1Rj", @videotron.instance_values['object'].instance_values['url']
        assert_equal "DN23wG8c1Rj", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Pau entra por la puerta grande en el club de los 10.000", :service => "Marca.tv"})
      end
    end



# ----------------------------------------------------------
#   Testing ted talks
# ----------------------------------------------------------
    context "with a ted talks video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.ted.com/index.php/talks/benjamin_wallace_on_the_price_of_happiness.html") # => Benjamin Wallace: Does happiness have a price tag?
      end
      should "initialize a VgTed instance" do
        assert_equal VgTed, @videotron.instance_values['object'].class
        assert_equal "http://www.ted.com/index.php/talks/benjamin_wallace_on_the_price_of_happiness.html", @videotron.instance_values['object'].instance_values['url']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
        assert_not_nil @videotron.instance_values['object'].instance_values['flashvars']
        assert_not_nil @videotron.instance_values['object'].instance_values['args']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Benjamin Wallace: Does happiness have a price tag?", :service => "Ted Talks"})
      end
    end
    
    context "with an invalid ted talks video url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.ted.com/index.php/wadus.html") }
      end
    end


# ----------------------------------------------------------
#   Testing vimeo
# ----------------------------------------------------------
    context "with a vimeo video url" do
      setup do
        @videotron = UnvlogIt.new("http://vimeo.com/2354261") # => People are strange
      end
      should "initialize a VgVimeo instance" do
        assert_equal VgVimeo, @videotron.instance_values['object'].class
        assert_equal "http://vimeo.com/2354261", @videotron.instance_values['object'].instance_values['url']
        assert_equal "2354261", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "People are strange", :service => "Vimeo"})
      end
    end


  protected
  
  def check_video_attributes(options={})
    assert_equal "#{options[:title]}", @videotron.title unless (options.blank? || options[:title].blank?)
    assert_equal "#{options[:service]}", @videotron.service unless (options.blank? || options[:service].blank?)
    assert_not_nil @videotron.thumbnail
    if options.blank? || options[:noembed].blank?
      assert_not_nil @videotron.embed_url
      assert_not_nil @videotron.embed_html
    elsif options[:noembed]
      assert_nil @videotron.embed_url
      assert_nil @videotron.embed_html
      assert_nil @videotron.video_details[:embed_url]
      assert_nil @videotron.video_details[:embed_html]
    end
    assert_not_nil @videotron.flv
    assert_equal Hash, @videotron.video_details.class
  end
end
