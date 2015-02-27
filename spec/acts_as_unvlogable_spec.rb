# encoding: utf-8
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
      expect(VgYoutube).to eq(videotron.instance_values['object'].class)
      expect("http://www.youtube.com/watch?v=MVa4q-YVjD8").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("MVa4q-YVjD8").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['details']).to_not be_nil
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

  context "with a shortened youtube URL" do
    let(:videotron) { UnvlogIt.new("http://youtu.be/4pzMBtPMUq8") } # => Keith Moon´s drum kit explodes

    it "initialize a VgYoutube instance" do
      expect(VgYoutu).to eq(videotron.instance_values['object'].class)
      expect("http://www.youtube.com/watch?&v=4pzMBtPMUq8").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("4pzMBtPMUq8").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['details']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "APM? Capítol 349 -09/04/14- (HD)", :service => "Youtube"})
    end
  end

  # ----------------------------------------------------------
  #   Testing metacafe
  # ----------------------------------------------------------

  context "with an existent metacafe url" do
    let(:videotron) { UnvlogIt.new("http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/") } # => Close Call! A320 Caught in Crosswinds

    it "initialize a VgMetacafe instance" do
      expect(VgMetacafe).to eq(videotron.instance_values['object'].class)
      expect("http://www.metacafe.com/watch/1135061/close_call_a320_caught_in_crosswinds/").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(3).to eq(videotron.instance_values['object'].instance_values['args'].size)
      expect(videotron.instance_values['object'].instance_values['yt']).to be_nil
      expect(videotron.instance_values['object'].instance_values['youtubed']).to be false
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Close call a320 caught in crosswinds", :service => "Metacafe"})
    end
  end

  context "with an existent 'youtubed' metacafe url" do
    let(:videotron) { UnvlogIt.new("http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/") } # => Pop Rocks and Coke Myth

    it "initialize a VgMetacafe instance" do
      expect(VgMetacafe).to eq(videotron.instance_values['object'].class)
      expect("http://www.metacafe.com/watch/yt-r07zdVLOWBA/pop_rocks_and_coke_myth/").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(3).to eq(videotron.instance_values['object'].instance_values['args'].size)
      expect("VgYoutube").to eq(videotron.instance_values['object'].instance_values['yt'].class.to_s)
      expect(videotron.instance_values['object'].instance_values['youtubed']).to be true
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Pop Rocks and Coke Myth", :service => "Metacafe"})
    end
  end

  # ----------------------------------------------------------
  #   Testing dailymotion
  # ----------------------------------------------------------

  context "with an existent dailymotion url" do
      let(:videotron) { UnvlogIt.new("http://www.dailymotion.com/video/x7u5kn_parkour-dayyy_sport/") } # => parkour dayyy

      it "initialize a VgDailymotion instance" do
        expect(VgDailymotion).to eq(videotron.instance_values['object'].class)
        expect("http://www.dailymotion.com/video/x7u5kn_parkour-dayyy_sport/").to eq(videotron.instance_values['object'].instance_values['url'])
        expect("x7u5kn_parkour-dayyy_sport").to eq(videotron.instance_values['object'].instance_values['video_id'])
        expect(videotron.instance_values['object'].instance_values['feed']).to_not be_nil
      end

      it "returns the video properties" do
        check_video_attributes({:title => "parkour dayyy", :service => "Dailymotion"})
      end
    end

  # ----------------------------------------------------------
  #   Testing collegehumor
  # ----------------------------------------------------------

  context "with an existent collegehumor url" do
    let(:videotron) { UnvlogIt.new("http://www.collegehumor.com/video/3005349/brohemian-rhapsody/") } # => Brohemian Rhapsody

    it "initialize a VgCollegehumor instance" do
      expect(VgCollegehumor).to eq(videotron.instance_values['object'].class)
      expect("http://www.collegehumor.com/video/3005349/brohemian-rhapsody/").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("3005349").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['feed']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Brohemian Rhapsody", :service => "CollegeHumor"})
    end
  end

  # ----------------------------------------------------------
  #   Testing blip.tv
  # ----------------------------------------------------------

  context "with an existent blip.tv url" do
    let(:videotron) { UnvlogIt.new("http://blip.tv/sarahrdtv/sarah-s-super-bowl-spread-healthy-recipe-classic-buffalo-wing-dip-6717535") } # => Sarah's Super Bowl Spread – Healthy Recipe - Classic Buffalo Wing Dip

    it "initialize a VgBlip instance" do
      expect(VgBlip).to eq(videotron.instance_values['object'].class)
      expect("http://blip.tv/sarahrdtv/sarah-s-super-bowl-spread-healthy-recipe-classic-buffalo-wing-dip-6717535").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['feed']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Sarah's Super Bowl Spread &#8211; Healthy Recipe - Classic Buffalo Wing Dip", :service => "Blip.tv"})
    end
  end

# ----------------------------------------------------------
#   Testing myspace.com
# ----------------------------------------------------------
  context "with an existent myspace.com url" do
    let(:videotron) { UnvlogIt.new("https://myspace.com/jimmykimmellive/video/mastodon-the-motherload-/109586961") } # => Mastodon - The Motherload

    it "initialize a VgMyspace instance" do
      expect(VgMyspace).to eq(videotron.instance_values['object'].class)
      expect("https://myspace.com/jimmykimmellive/video/mastodon-the-motherload-/109586961").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Mastodon - The Motherload", :service => "Myspace"})
    end
  end


# ----------------------------------------------------------
#   Testing 11870.com
# ----------------------------------------------------------
  context "with an existent 11870.com url" do
    let(:videotron) { UnvlogIt.new("http://11870.com/pro/chic-basic-born/media/b606abfe") } # => Chic & Basic Born

    it "initialize a Vg11870 instance" do
      expect(Vg11870).to eq(videotron.instance_values['object'].class)
      expect("https://11870.com/pro/chic-basic-born/media/b606abfe").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Chic & Basic Born", :service => "11870.com"})
    end
  end


# ----------------------------------------------------------
#   Testing dalealplay.com
# ----------------------------------------------------------
  context "with an existent dalealplay.com url" do
    let(:videotron) { UnvlogIt.new("http://www.dalealplay.com/informaciondecontenido.php?con=80280") } # => Camelos Semos  Jonathan  Tú si que vales

    it "initialize a VgDalealplay instance" do
      expect(VgDalealplay).to eq(videotron.instance_values['object'].class)
      expect("http://www.dalealplay.com/informaciondecontenido.php?con=80280").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("80280").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Camelos.Semos. Jonathan. Tú si que vales.", :service => "dalealplay"})
    end
  end


# ----------------------------------------------------------
#   Testing flickr.com
# ----------------------------------------------------------
  context "with a flickr.com video url" do
    let(:videotron) { UnvlogIt.new("http://www.flickr.com/photos/jerovital/4152225414/", {:key => "065b2eff5e604e2a408c01af1f27a982" }) }# => flipando en los columpios

    it "initialize a VgFlickr instance" do
      expect(VgFlickr).to eq(videotron.instance_values['object'].class)
      expect("http://www.flickr.com/photos/jerovital/4152225414/").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("4152225414").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['details']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "flipando en los columpios", :service => "Flickr"})
    end
  end


# ----------------------------------------------------------
#   Testing ted talks
# ----------------------------------------------------------
  context "with an existent ted talks url" do
    let(:videotron) { UnvlogIt.new("http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness") } # => Benjamin Wallace: Does happiness have a price tag?

    it "initialize a VgTed instance" do
      expect(VgTed).to eq(videotron.instance_values['object'].class)
      expect("http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "The price of happiness", :service => "Ted Talks"})
    end
  end

  context "with a non existent ted talks url" do
    it "should raise an error" do
      expect{ UnvlogIt.new("http://www.ted.com/index.php/wadus.html") }.to raise_error(ArgumentError, "Unsuported url or service")
    end
  end


# ----------------------------------------------------------
#   Testing vimeo
# ----------------------------------------------------------
  context "with an existent vimeo url" do
    let(:videotron) { UnvlogIt.new("http://vimeo.com/119318850") } # => Gotham City SF // A Timelapse Film

    it "initialize a VgVimeo instance" do
      expect(VgVimeo).to eq(videotron.instance_values['object'].class)
      expect("http://vimeo.com/119318850").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("119318850").to eq(videotron.instance_values['object'].instance_values['video_id'])
      expect(videotron.instance_values['object'].instance_values['feed']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Gotham City SF // A Timelapse Film", :service => "Vimeo"})
    end
  end


# ----------------------------------------------------------
#   Testing RuTube
# ----------------------------------------------------------
  context "with an existent rutube url" do
    let(:videotron) { UnvlogIt.new("http://rutube.ru/video/520685fa20c456e200e683f3df17b131/") } # => chipmunks!!

    it "initialize a VgRutube instance" do
      expect(VgRutube).to eq(videotron.instance_values['object'].class)
      expect("http://rutube.ru/video/520685fa20c456e200e683f3df17b131/").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Запасливые бурундуки", :service => "Rutube"})
    end
  end

  context "with an invalid rutube url" do
    it "should raise an error" do
      expect{ UnvlogIt.new("http://rutube.ru/tracks/abdcd.html?v=523423") }.to raise_error(ArgumentError, "Unsuported url or service")
    end
  end

# ----------------------------------------------------------
#   Testing Prostopleer
# ----------------------------------------------------------
  context "with an existent pleer url" do
    let(:videotron) { UnvlogIt.new("http://pleer.com/tracks/3370305QRJl") } # => La mala rodriguez, Nach Scratch SFDK - Dominicana

    it "initialize a VgPleer instance" do
      expect(VgPleer).to eq(videotron.instance_values['object'].class)
      expect("http://pleer.com/tracks/3370305QRJl").to eq(videotron.instance_values['object'].instance_values['url'])
      expect("3370305QRJl").to eq(videotron.instance_values['object'].instance_values['track_id'])
      expect("Pleer").to eq(videotron.service)
      expect(videotron.embed_html).not_to be_nil
      expect("La mala rodriguez, Nach Scratch  SFDK - Dominicana").to eq(videotron.title)
    end
  end

  context "with an invalid pleer url" do
    it "should raise an error" do
      expect{ UnvlogIt.new("http://prostopleer.com/trackszz/401758bI6n") }.to raise_error(ArgumentError, "Unsuported url or service")
    end
  end


# ----------------------------------------------------------
#   Testing Wistia
# ----------------------------------------------------------
  context "with an existent wistia url" do
    let(:videotron) { UnvlogIt.new("https://home.wistia.com/medias/e4a27b971d") } # => Brendan - Make It Clap

    it "initialize a VgWistia instance" do
      expect(VgWistia).to eq(videotron.instance_values['object'].class)
      expect("https://home.wistia.com/medias/e4a27b971d").to eq(videotron.instance_values['object'].instance_values['url'])
    end

    it "returns the video properties" do
      check_video_attributes({
          :title         => "Brendan - Make It Clap",
          :service       => "Wistia, Inc.",
          :duration      => 16.43,
          :thumbnail     => "https://embed-ssl.wistia.com/deliveries/2d2c14e15face1e0cc7aac98ebd5b6f040b950b5.jpg?image_crop_resized=640x360"
      })
    end
  end

  context "with a non existent wistia url" do
    it "should raise an error" do
      expect{ UnvlogIt.new("https://gadabouting.wistia.com/medias/inexistent") }.to raise_error(ArgumentError, "Unsuported url or service")
    end
  end

protected

def check_video_attributes(options={})
  expect(options[:title]).to eq(videotron.title) unless (options.blank? || options[:title].blank?)
  expect(options[:service]).to eq(videotron.service) unless (options.blank? || options[:service].blank?)
  expect(videotron.thumbnail).not_to be_nil
  if options.blank? || options[:noembed].blank?
    expect(videotron.embed_url).not_to be_nil
    expect(videotron.embed_html).not_to be_nil
  elsif options[:noembed]
    expect(videotron.embed_url).to be_nil
    expect(videotron.embed_html).to be_nil
    expect(videotron.video_details[:embed_url]).to be_nil
    expect(videotron.video_details[:embed_html]).to be_nil
  end
  expect(videotron.flv).to be_nil
  expect(Hash).to eq(videotron.video_details.class)
end
end