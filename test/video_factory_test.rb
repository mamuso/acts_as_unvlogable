# encoding: utf-8
require 'test/unit'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
# Main class
require 'acts_as_unvlogable'
# Gems & other herbs
require 'shoulda'
require 'ruby-debug'

class NoEmbedServiceDouble
  def initialize
    @details = self
  end

  def noembed
    true
  end
end

class ActsAsUnvlogableFactoryTest < Test::Unit::TestCase
  context UnvlogIt::VideoFactory do
    should "return a Vg service object" do
      url = "http://vimeo.com/1234567"
      service = UnvlogIt::VideoFactory.new(url).load_service

      assert_equal VgVimeo, service.class
    end

    context "bad urls" do
      should "raise an exception if no url is provided" do
        assert_raise(ArgumentError) do
          UnvlogIt::VideoFactory.new(nil)
        end
      end

      # TODO this should be a NotImplementedError, but leaving as ArgumentError
      # for backwards support.
      should "raise an exception if we haven't implemented support for that URL" do
        assert_raise(ArgumentError) do
          UnvlogIt::VideoFactory.new("http://my-video-service.com/horse_apples").load_service
        end
      end

      should "raise an exception if we have an invalid URL" do
        # underscores are not permitted by URI::parse
        assert_raise(URI::InvalidURIError) do
          UnvlogIt::VideoFactory.new("http://my_video_service.com/horse_apples").load_service
        end
      end

      should "raise an exception if our service object does not allow it" do
        factory = UnvlogIt::VideoFactory.new("url")

        # factory.stubs(:service_object).returns(service_double)
        def factory.service_object
          NoEmbedServiceDouble.new
        end

        assert_raise(ArgumentError, "Embedding disabled by request") do
          factory.load_service
        end
      end
    end
  end
end
