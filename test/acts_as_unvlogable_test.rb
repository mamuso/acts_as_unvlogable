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
        assert_equal "Ninja cat comes closer while not moving!", @videotron.title
        assert_not_nil @videotron.thumbnail
        assert_not_nil @videotron.embed_url
        assert_not_nil @videotron.embed_html
        assert_not_nil @videotron.flv
        assert_equal Hash, @videotron.video_details.class
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
        assert_equal "The Killers - Read My Mind", @videotron.title
        assert_not_nil @videotron.thumbnail
        assert_not_nil @videotron.flv
        assert_equal Hash, @videotron.video_details.class
        assert_nil @videotron.embed_url
        assert_nil @videotron.embed_html
        assert_nil @videotron.video_details[:embed_url]
        assert_nil @videotron.video_details[:embed_html]
      end
    end
    
    context "with an inexistent youtube url" do
      should "raise an ArgumentError" do
        assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.youtube.com/watch?v=inexistente", {:key => "RCofu-vAmeY"}) }
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
      end
      
      should "return the video properties" do
        assert_equal "Close call a320 caught in crosswinds", @videotron.title
        assert_not_nil @videotron.thumbnail
        assert_not_nil @videotron.embed_url
        assert_not_nil @videotron.embed_html
        assert_not_nil @videotron.flv
        assert_equal Hash, @videotron.video_details.class
      end
    end
    
    
    
  end
  
end
