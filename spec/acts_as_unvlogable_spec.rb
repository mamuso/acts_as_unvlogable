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

    it "initialize a VgYoutube instance" do
      VgYoutube.should eq(videotron.instance_values['object'].class)
      "http://www.youtube.com/watch?v=MVa4q-YVjD8".should eq(videotron.instance_values['object'].instance_values['url'])
      "MVa4q-YVjD8".should eq(videotron.instance_values['object'].instance_values['video_id'])
      videotron.instance_values['object'].instance_values['details'].should_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Keith Moon´s drum kit explodes", :service => "Youtube"})
    end
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

  protected
  
  def check_video_attributes(options={})
    options[:title].should eq(videotron.title) unless (options.blank? || options[:title].blank?)
    options[:service].should eq(videotron.service) unless (options.blank? || options[:service].blank?)

    videotron.thumbnail.should_not be_nil
    if options.blank? || options[:noembed].blank?
      videotron.embed_url.should_not be_nil
      videotron.embed_html.should_not be_nil
    elsif options[:noembed]
      videotron.embed_url.should be_nil
      videotron.embed_html.should be_nil
      videotron.video_details[:embed_url].should be_nil
      videotron.video_details[:embed_html].should be_nil
    end
     videotron.flv.should be_nil
     Hash.should eq(videotron.video_details.class)
  end
end