require 'spec_helper'

describe UnvlogIt do
  context "without any url" do
    it {
      expect { UnvlogIt.new }.to raise_error(ArgumentError, "We need a video url")
    }
  end

  context "with an unsupported url" do
    it {
      expect { UnvlogIt.new("http://iwannagothere.net") }.to raise_error(ArgumentError, "Unsuported url or service")
    }
  end

  # ----------------------------------------------------------
  #   Testing youtube
  # ----------------------------------------------------------

  context "with an existent youtube url" do
    let(:videotron) { UnvlogIt.new("http://www.youtube.com/watch?v=MVa4q-YVjD8") } # => Keith Moon´s drum kit explodes


    # should "initialize a VgYoutube instance" do
    #     assert_equal VgYoutube, @videotron.instance_values['object'].class
    #     assert_equal "http://www.youtube.com/watch?v=MVa4q-YVjD8", @videotron.instance_values['object'].instance_values['url']
    #     assert_equal "MVa4q-YVjD8", @videotron.instance_values['object'].instance_values['video_id']
    #     assert_not_nil @videotron.instance_values['object'].instance_values['details']
    #   end

    #   should "return the video properties" do
    #     check_video_attributes({:title => "Keith Moon´s drum kit explodes", :service => "Youtube"})
    #   end
  end

  context "with an existent youtube url that can not be embedded" do
    it {
      expect { UnvlogIt.new("https://www.youtube.com/watch?v=-PZYZ6fJbr4") }.to raise_error(ArgumentError, "Embedding disabled by request")
    }
  end

  context "with an inexistent youtube url" do
    it {
      expect { UnvlogIt.new("http://www.youtube.com/watch?v=inexistente") }.to raise_error(ArgumentError, "Unsuported url or service")
    }
  end

end