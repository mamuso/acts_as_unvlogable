require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'active_support'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
# Main class
require 'videogrinder'
# Gems & other herbs
require 'open-uri'
require 'youtube'
# Video classes
require 'vg_youtube'
require 'vg_google'


class VideogrinderTest < Test::Unit::TestCase
  
  context "Instancing Videogrinder" do
    
    context "without any url" do
      should "raise an ArgumentError exception" do
        assert_raise(ArgumentError, "We need a video url") { Videogrinder.new }
      end
    end
    
    context "with an unsupported url" do
      should "raise a NameError exception" do
        assert_raise(NameError, "uninitialized constant VgIwannagothere") { Videogrinder.new("http://iwannagothere.net/") }
      end
    end
    
  end
  
end
