require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'active_support'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
# Main class
require 'acts_as_unvlogable'
# Gems & other herbs
require 'open-uri'
require 'youtube'
# Video classes
require 'vg_youtube'
require 'vg_google'
require 'vg_metacafe'
require 'vg_dailymotion'


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
        @videotron = UnvlogIt.new("http://www.youtube.com/watch?v=muLIPWjks_M", {:key => "RCofu-vAmeY"}) # => Ninja cat comes closer while not moving!
      end
      should "initialize a VgYoutube instance" do
        assert_equal VgYoutube, @videotron.instance_values['object'].class
        assert_equal "http://www.youtube.com/watch?v=muLIPWjks_M", @videotron.instance_values['object'].instance_values['url']
        assert_equal "muLIPWjks_M", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Ninja cat comes closer while not moving!"})
      end
    end


    context "with an existent youtube url that can not be embedded" do
      setup do
        @videotron = UnvlogIt.new("http://www.youtube.com/watch?v=3Oec8RuwVVs", {:key => "RCofu-vAmeY"}) # => The Killers - Read My Mind
      end
      should "initialize a VgYoutube instance" do
        assert_equal VgYoutube, @videotron.instance_values['object'].class
        assert_equal "http://www.youtube.com/watch?v=3Oec8RuwVVs", @videotron.instance_values['object'].instance_values['url']
        assert_equal "3Oec8RuwVVs", @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['details']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "The Killers - Read My Mind", :noembed => true})
      end
    end
    
    context "with an inexistent youtube url" do
      should "raise an ArgumentError" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.youtube.com/watch?v=inexistente", {:key => "RCofu-vAmeY"}) }
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
        assert_equal 4798198171297333202, @videotron.instance_values['object'].instance_values['video_id']
        assert_not_nil @videotron.instance_values['object'].instance_values['feed']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Pocoyo. Musica Maestro"})
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
        @videotron = UnvlogIt.new("http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/", {:key => "RCofu-vAmeY"}) # => Close Call! A320 Caught in Crosswinds 
      end
      should "initialize a VgMetacafe instance" do
        assert_equal VgMetacafe, @videotron.instance_values['object'].class
        assert_equal "http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/", @videotron.instance_values['object'].instance_values['url']
        assert_equal 3, @videotron.instance_values['object'].instance_values['args'].size
        assert !@videotron.instance_values['object'].instance_values['youtubed']
        assert_nil @videotron.instance_values['object'].instance_values['yt']
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Close call a320 caught in crosswinds"})
      end
    end
    
    context "with an existent 'youtubed' metacafe url" do
      setup do
        @videotron = UnvlogIt.new("http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/", {:key => "RCofu-vAmeY"}) # => Close Call! A320 Caught in Crosswinds 
      end
      should "initialize a VgMetacafe instance" do
        assert_equal VgMetacafe, @videotron.instance_values['object'].class
        assert_equal "http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/", @videotron.instance_values['object'].instance_values['url']
        assert_equal 3, @videotron.instance_values['object'].instance_values['args'].size
        assert @videotron.instance_values['object'].instance_values['youtubed']
        assert VgYoutube, @videotron.instance_values['object'].instance_values['yt'].class
      end
      
      should "return the video properties" do
        check_video_attributes({:title => "Pop Rocks and Coke Myth"})
      end
    end
    
    
  end


# ----------------------------------------------------------
#   Testing dailymotion
# ----------------------------------------------------------
    context "with an dailymotion video url" do
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
        check_video_attributes({:title => "parkour dayyy"})
      end
    end
  
  protected
  
  def check_video_attributes(options={})
    assert_equal "#{options[:title]}", @videotron.title unless (options.blank? || options[:title].blank?)
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
