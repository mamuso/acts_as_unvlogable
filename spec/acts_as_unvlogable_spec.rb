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
  #   Testing vids.myspace.com
  # ----------------------------------------------------------
  
  # Service changed, check the new urls
  # https://myspace.com/jimmykimmellive/video/mastodon-the-motherload-/109586961

  # context "with a vids.myspace.com video url" do
  #   let(:videotron) { UnvlogIt.new("http://vids.myspace.com/index.cfm?fuseaction=vids.individual&VideoID=27111431") } # => rocabilis

  #   it "initialize a VgMyspace instance" do
  #     expect(VgBlip).to eq(videotron.instance_values['object'].class)
  #     expect("http://vids.myspace.com/index.cfm?fuseaction=vids.individual&VideoID=27111431").to eq(videotron.instance_values['object'].instance_values['url'])
  #     expect("27111431").to eq(videotron.instance_values['object'].instance_values['video_id'])
  #     expect(videotron.instance_values['object'].instance_values['feed']).to_not be_nil
  #   end

  #   it "returns the video properties" do
  #     check_video_attributes({:title => "rocabilis", :service => "Myspace"})
  #   end
  # end


# ----------------------------------------------------------
#   Testing 11870.com
# ----------------------------------------------------------

  context "with an existent 11870.com url" do
    let(:videotron) { Vg11870.new("http://11870.com/pro/chic-basic-born/media/b606abfe") } # => Chic & Basic Born

    it "initialize a Vg11870 instance" do
      expect(Vg11870).to eq(videotron.instance_values['object'].class)
      expect("https://11870.com/pro/chic-basic-born/media/b606abfe").to eq(videotron.instance_values['object'].instance_values['url'])
      expect(videotron.instance_values['object'].instance_values['page']).to_not be_nil
      expect(videotron.instance_values['object'].instance_values['flashvars']).to_not be_nil
    end

    it "returns the video properties" do
      check_video_attributes({:title => "Chic & Basic Born", :service => "11870.com"})
    end
  end


# # ----------------------------------------------------------
# #   Testing dalealplay.com
# # ----------------------------------------------------------
#     context "with a dalealplay.com video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://www.dalealplay.com/informaciondecontenido.php?con=80280") # => Camelos Semos  Jonathan  Tú si que vales
#       end
#       should "initialize a VgDalealplay instance" do
#         assert_equal "VgDalealplay", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://www.dalealplay.com/informaciondecontenido.php?con=80280", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "80280", @videotron.instance_values['object'].instance_values['video_id']
#         assert_not_nil @videotron.instance_values['object'].instance_values['page']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "Camelos.Semos. Jonathan. Tú si que vales.", :service => "dalealplay"}) 
#       end
#     end



# # ----------------------------------------------------------
# #   Testing flickr.com
# # ----------------------------------------------------------
#     context "with a flickr.com video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://www.flickr.com/photos/jerovital/4152225414/", {:key => "065b2eff5e604e2a408c01af1f27a982" }) # => la primera vela
#       end
#       should "initialize a VgFlickr instance" do
#         assert_equal "VgFlickr", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://www.flickr.com/photos/jerovital/4152225414/", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "4152225414", @videotron.instance_values['object'].instance_values['video_id']
#         assert_not_nil @videotron.instance_values['object'].instance_values['details']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "flipando en los columpios", :service => "Flickr"})
#       end
#     end


# # ----------------------------------------------------------
# #   Testing qik.com
# # ----------------------------------------------------------
#     context "with a qik.com video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://qik.com/video/340982") # => Honolulu Day 8: USS Arizona at Pearl Harbor
#       end
#       should "initialize a VgQik instance" do
#         assert_equal "VgQik", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://qik.com/video/340982", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "340982", @videotron.instance_values['object'].instance_values['video_id']
#         assert_not_nil @videotron.instance_values['object'].instance_values['page']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "Honolulu Day 8: USS Arizona at Pearl Harbor", :service => "Qik"})
#       end
#     end



# # ----------------------------------------------------------
# #   Testing www.marca.tv
# # ----------------------------------------------------------
#     context "with a www.marca.tv video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://www.marca.com/tv/?v=DN23wG8c1Rj") # => Pau entra por la puerta grande en el club de los 10.000
#       end
#       should "initialize a VgMarca instance" do
#         assert_equal "VgMarca", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://www.marca.com/tv/?v=DN23wG8c1Rj", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "DN23wG8c1Rj", @videotron.instance_values['object'].instance_values['video_id']
#         assert_not_nil @videotron.instance_values['object'].instance_values['feed']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "Pau entra por la puerta grande en el club de los 10.000", :service => "Marca.tv"})
#       end
#     end



# # ----------------------------------------------------------
# #   Testing ted talks
# # ----------------------------------------------------------
#     context "with a ted talks video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html") # => Benjamin Wallace: Does happiness have a price tag?
#       end
#       should "initialize a VgTed instance" do
#         assert_equal "VgTed", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://www.ted.com/talks/benjamin_wallace_on_the_price_of_happiness.html", @videotron.instance_values['object'].instance_values['url']
#         assert_not_nil @videotron.instance_values['object'].instance_values['page']
#         assert_not_nil @videotron.instance_values['object'].instance_values['flashvars']
#         assert_not_nil @videotron.instance_values['object'].instance_values['args']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "Benjamin Wallace: The price of happiness", :service => "Ted Talks"})
#       end
#     end

#     context "with an invalid ted talks video url" do
#       should "raise an ArgumentError exception" do
#         assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://www.ted.com/index.php/wadus.html") }
#       end
#     end


# # ----------------------------------------------------------
# #   Testing vimeo
# # ----------------------------------------------------------
#     context "with a vimeo video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://vimeo.com/2354261") # => People are strange
#       end
#       should "initialize a VgVimeo instance" do
#         assert_equal "VgVimeo", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://vimeo.com/2354261", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "2354261", @videotron.instance_values['object'].instance_values['video_id']
#         assert_not_nil @videotron.instance_values['object'].instance_values['feed']
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "People are strange", :service => "Vimeo"})
#       end
#     end

# # ----------------------------------------------------------
# #   Testing RuTube
# # ----------------------------------------------------------
#     context "with a rutube video url" do
#       setup do
#         @videotron = UnvlogIt.new("http://rutube.ru/tracks/1958807.html?v=56cd2f1b50a4d2b69ff455e72f2fae29") # => chipmunks!!
#       end
#       should "initialize a VgRutube instance" do
#         assert_equal "VgRutube", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://rutube.ru/tracks/1958807.html?v=56cd2f1b50a4d2b69ff455e72f2fae29", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "1958807", @videotron.instance_values['object'].instance_values['movie_id']
#         assert_equal "56cd2f1b50a4d2b69ff455e72f2fae29", @videotron.instance_values['object'].send(:movie_hash)
#       end

#       should "return the video properties" do
#         check_video_attributes({:title => "Запасливые бурундуки"})
#       end
#     end

#     context "with an invalid rutube video url" do
#       should "raise an ArgumentError exception" do
#         assert_raise(ArgumentError, "Unsuported url or service") { UnvlogIt.new("http://rutube.ru/tracks/abdcd.html?v=523423") }
#       end
#     end

# # ----------------------------------------------------------
# #   Testing Prostopleer
# # ----------------------------------------------------------
#     context "with a prostopleer url" do
#       setup do
#         @videotron = UnvlogIt.new("http://prostopleer.com/tracks/401758bI6n")
#       end
#       should "initialize a VgProstopleer instance" do
#         assert_equal "VgProstopleer", @videotron.instance_values['object'].class.to_s
#         assert_equal "http://prostopleer.com/tracks/401758bI6n", @videotron.instance_values['object'].instance_values['url']
#         assert_equal "401758bI6n", @videotron.instance_values['object'].instance_values['track_id']
#         assert_equal "Combichrist - sent to destroy", @videotron.title
#       end
#     end

#     context "with an invalid prostopleer url" do
#       should "raise an ArgumentError exception" do
#         assert_raise(ArgumentError) { UnvlogIt.new("http://prostopleer.com/trackszz/401758bI6n") }
#       end
#     end

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