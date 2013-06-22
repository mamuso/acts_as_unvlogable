# encoding: utf-8
require 'test/unit'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
# Main class
require 'acts_as_unvlogable'
# Gems & other herbs
require 'shoulda'
require 'ruby-debug'

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
        @videotron = UnvlogIt.new("http://www.youtube.com/watch?v=MVa4q-YVjD8") # => Keith Moon´s drum kit explodes
      end
      should "initialize a VgYoutube instance" do
        assert_equal VgYoutube, @videotron.instance_values['object'].class
        assert_equal "http://www.youtube.com/watch?v=MVa4q-YVjD8", @videotron.instance_values['object'].instance_values['url']
        assert_equal "MVa4q-YVjD8", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Keith Moon´s drum kit explodes", :service => "Youtube"})
      end
    end

    context "with an existent youtube url that can not be embedded" do
        should "raise an ArgumentError" do
          assert_raise(ArgumentError, "Embedding disabled by request") { UnvlogIt.new("http://www.youtube.com/watch?v=6TT19cB0NTM") }# => Oh! Yeah! by Chickenfoot from the Tonight Show w Conan O'Brien 
        end
    end
    
    context "with an inexistent youtube url" do
      should "raise an ArgumentError" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.youtube.com/watch?v=inexistente") }
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
        assert "VgYoutube", @videotron.instance_values['object'].instance_values['yt'].class.to_s
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
        assert_equal "VgDailymotion", @videotron.instance_values['object'].class.to_s
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
        @videotron = UnvlogIt.new("http://www.collegehumor.com/video/3005349/brohemian-rhapsody") # => Brohemian Rhapsody
      end
      should "initialize a VgCollegehumor instance" do
        assert_equal "VgCollegehumor", @videotron.instance_values['object'].class.to_s
        assert_equal "http://www.collegehumor.com/video/3005349/brohemian-rhapsody", @videotron.instance_values['object'].instance_values['url']
        assert_equal "3005349", @videotron.instance_values['object'].instance_values['video_id']
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
        assert_equal "VgBlip", @videotron.instance_values['object'].class.to_s
        assert_equal "http://blip.tv/file/678407/", @videotron.instance_values['object'].instance_values['url']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Toy Break 26 : Adult Toys", :service => "Blip.tv"})
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
        assert_equal "VgMyspace", @videotron.instance_values['object'].class.to_s
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
        assert_equal "Vg11870", @videotron.instance_values['object'].class.to_s
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
        assert_equal "VgDalealplay", @videotron.instance_values['object'].class.to_s
        assert_equal "http://www.dalealplay.com/informaciondecontenido.php?con=80280", @videotron.instance_values['object'].instance_values['url']
        assert_equal "80280", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Camelos.Semos. Jonathan. Tú si que vales.", :service => "dalealplay"}) 
      end
    end



# ----------------------------------------------------------
#   Testing flickr.com
# ----------------------------------------------------------
    context "with a flickr.com video url" do
      setup do
        @videotron = UnvlogIt.new("http://www.flickr.com/photos/jerovital/4152225414/", {:key => "065b2eff5e604e2a408c01af1f27a982" }) # => la primera vela
      end
      should "initialize a VgFlickr instance" do
        assert_equal "VgFlickr", @videotron.instance_values['object'].class.to_s
        assert_equal "http://www.flickr.com/photos/jerovital/4152225414/", @videotron.instance_values['object'].instance_values['url']
        assert_equal "4152225414", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "flipando en los columpios", :service => "Flickr"})
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
        assert_equal "VgQik", @videotron.instance_values['object'].class.to_s
        assert_equal "http://qik.com/video/340982", @videotron.instance_values['object'].instance_values['url']
        assert_equal "340982", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
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
        assert_equal "VgMarca", @videotron.instance_values['object'].class.to_s
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
        @videotron = UnvlogIt.new("http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html") # => Benjamin Wallace: Does happiness have a price tag?
      end
      should "initialize a VgTed instance" do
        assert_equal "VgTed", @videotron.instance_values['object'].class.to_s
        assert_equal "http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html", @videotron.instance_values['object'].instance_values['url']
        assert_not_nil @videotron.instance_values['object'].instance_values['page']
        assert_not_nil @videotron.instance_values['object'].instance_values['flashvars']
        assert_not_nil @videotron.instance_values['object'].instance_values['args']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Benjamin Wallace: The price of happiness", :service => "Ted Talks"})
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
        assert_equal "VgVimeo", @videotron.instance_values['object'].class.to_s
        assert_equal "http://vimeo.com/2354261", @videotron.instance_values['object'].instance_values['url']
        assert_equal "2354261", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "People are strange", :service => "Vimeo"})
      end
    end

# ----------------------------------------------------------
#   Testing RuTube
# ----------------------------------------------------------
    context "with a rutube video url" do
      setup do
        @videotron = UnvlogIt.new("http://rutube.ru/tracks/1958807.html?v=56cd2f1b50a4d2b69ff455e72f2fae29") # => chipmunks!!
      end
      should "initialize a VgRutube instance" do
        assert_equal "VgRutube", @videotron.instance_values['object'].class.to_s
        assert_equal "http://rutube.ru/tracks/1958807.html?v=56cd2f1b50a4d2b69ff455e72f2fae29", @videotron.instance_values['object'].instance_values['url']
        assert_equal "1958807", @videotron.instance_values['object'].instance_values['movie_id']
        assert_equal "56cd2f1b50a4d2b69ff455e72f2fae29", @videotron.instance_values['object'].send(:movie_hash)
      end

      should "return the video properties" do
        check_video_attributes({:title => "Запасливые бурундуки"})
      end
    end

    context "with an invalid rutube video url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://rutube.ru/tracks/abdcd.html?v=523423") }
      end
    end
    
# ----------------------------------------------------------
#   Testing Prostopleer
# ----------------------------------------------------------
    context "with a prostopleer url" do
      setup do
        @videotron = UnvlogIt.new("http://prostopleer.com/tracks/401758bI6n")
      end
      should "initialize a VgProstopleer instance" do
        assert_equal "VgProstopleer", @videotron.instance_values['object'].class.to_s
        assert_equal "http://prostopleer.com/tracks/401758bI6n", @videotron.instance_values['object'].instance_values['url']
        assert_equal "401758bI6n", @videotron.instance_values['object'].instance_values['track_id']
        assert_equal "Combichrist - sent to destroy", @videotron.title
      end
    end

    context "with an invalid prostopleer url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError) { UnvlogIt.new("http://prostopleer.com/trackszz/401758bI6n") }
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
