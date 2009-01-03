# included here to skip the gem dependency

#--
# Copyright (c) 2006 Shane Vitarana
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'net/http'
require 'xmlsimple'
require 'cgi'

module YouTube

  class Category
    FILMS_ANIMATION = 1
    AUTOS_VEHICLES = 2
    COMEDY = 23
    ENTERTAINMENT = 24
    MUSIC = 10
    NEWS_POLITICS = 25
    PEOPLE_BLOGS = 22
    PETS_ANIMALS = 15
    HOWTO_DIY = 26
    SPORTS = 17
    TRAVEL_PLACES = 19
    GADGETS_GAMES = 20    
  end
  
  # Main client class managing all interaction with the YouTube server.
  # Server communication is handled via method_missing() emulating an
  # RPC-like call and performing all of the work to send out the HTTP
  # request and retrieve the XML response.  Inspired by the Flickr
  # interface by Scott Raymond <http://redgreenblu.com/flickr/>.
  class Client
    # the default hostname at which the YouTube API is hosted
    DEFAULT_HOST = 'http://www.youtube.com'
    # the default api path to the YouTube API
    DEFAULT_API_PATH = '/api2_rest'
    
    def initialize(dev_id = nil, host = DEFAULT_HOST, api_path = DEFAULT_API_PATH)
      raise "developer id required" unless dev_id

      @host = host
      @api_path = api_path
      @dev_id = dev_id
    end

    # Returns a YouTube::Profile object detailing the profile information
    # regarding the supplied +username+.
    def profile(username)
      response = users_get_profile(:user => username)
      Profile.new response['user_profile']
    end

    # Returns a list of YouTube::Video objects detailing the favorite
    # videos of the supplied +username+.
    def favorite_videos(username)
      response = users_list_favorite_videos(:user => username)
      _parse_video_response(response)
    end

    # Returns a list of YouTube::Friend objects detailing the friends of
    # the supplied +username+.
    def friends(username)
      response = users_list_friends(:user => username)
      friends = response['friend_list']['friend']
      friends.is_a?(Array) ? friends.compact.map { |friend| Friend.new(friend) } : nil        
    end

    # Returns a list of YouTube::Video objects detailing the videos
    # matching the supplied +tag+.
    #
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_tag(tag, page = 1, per_page = 20)
      response = videos_list_by_tag(:tag => tag, :page => page, :per_page => per_page)
      _parse_video_response(response)
    end

    # Returns a list of YouTube::Video objects that match the
    # specified +tag+.
    #
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_related(tag, page = 1, per_page = 20)
      response = videos_list_by_related(:tag => tag, :page => page, :per_page => per_page)
      _parse_video_response(response)
    end

    # Returns a list of YouTube::Video objects with the specified
    # playlist +id+.
    #
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_playlist(id, page = 1, per_page = 20)
      response = videos_list_by_playlist(:id => id, :page => page, :per_page => per_page)
      _parse_video_response(response)
    end

    # Returns a list of YouTube::Video objects detailing the videos
    # matching the supplied category +id+ and +tag+.
    #
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_category_id_and_tag(id, tag, page = 1, per_page = 20)
      response = videos_list_by_category_and_tag(:category_id => id, :tag => tag, :page => page, :per_page => per_page)
      _parse_video_response(response)
    end

    # Returns a list of YouTube::Video objects detailing the videos
    # matching the supplied +category+ and +tag+.
    #
    # Available categories:
    # YouTube::Category::FILMS_ANIMATION
    # YouTube::Category::AUTOS_VEHICLES
    # YouTube::Category::COMEDY
    # YouTube::Category::ENTERTAINMENT
    # YouTube::Category::MUSIC
    # YouTube::Category::NEWS_POLITICS
    # YouTube::Category::PEOPLE_BLOGS
    # YouTube::Category::PETS_ANIMALS
    # YouTube::Category::HOWTO_DIY
    # YouTube::Category::SPORTS
    # YouTube::Category::TRAVEL_PLACES
    # YouTube::Category::GADGETS_GAMES
    #    
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_category_and_tag(category, tag, page = 1, per_page = 20)
      videos_by_category_id_and_tag(category, tag, page, per_page)
    end

    # Returns a list of YouTube::Video objects detailing the videos
    # uploaded by the specified +username+.
    #
    # Optional parameters are:
    # +page+ = the "page" of results to retrieve (e.g. 1, 2, 3)
    # +per_page+ = the number of results per page (default: 20, max 100).
    def videos_by_user(username, page = 1, per_page = 20)
      response = videos_list_by_user(:user => username, :page => page, :per_page => per_page)
       _parse_video_response(response)
     end
    
    # Returns a list of YouTube::Video objects detailing the current
    # global set of featured videos on YouTube.
    def featured_videos
      response = videos_list_featured
      _parse_video_response(response)
    end

    # Returns a YouTube::VideoDetails object detailing additional
    # information on the supplied video id, obtained from a
    # YouTube::Video object from a previous client call.
    def video_details(video_id)
      raise ArgumentError.new("invalid video id parameter, must be string") unless video_id.is_a?(String)
      response = videos_get_details(:video_id => video_id)
      VideoDetails.new(response['video_details'])
    end

    private
      # All API methods are implemented with this method.  This method is
      # like a remote method call, it encapsulates the request/response
      # cycle to the remote host. It extracts the remote method API name
      # based on the ruby method name.
      def method_missing(method_id, *params)
        _request(method_id.to_s.sub('_', '.'), *params)
      end

      def _request(method, *params)
        url = _request_url(method, *params)
        response = XmlSimple.xml_in(_http_get(url), { 'ForceArray' => [ 'video', 'friend' ] })
        raise response['error']['description'] + " : url=#{url}" unless response['status'] == 'ok' 
        response
      end

      def _request_url(method, *params)
        param_list = String.new
        unless params.empty?
          params.first.each_pair { |k, v| param_list << "&#{k.to_s}=#{CGI.escape(v.to_s)}" }
        end
        url = "#{@host}#{@api_path}?method=youtube.#{method}&dev_id=#{@dev_id}#{param_list}"
      end

      def _http_get(url)
        Net::HTTP.get_response(URI.parse(url)).body.to_s
      end

      def _parse_video_response(response)
        videos = response['video_list']['video']
        videos.is_a?(Array) ? videos.compact.map { |video| Video.new(video) } : nil        
      end
  end

  class Friend
    attr_reader :favorite_count
    attr_reader :friend_count
    attr_reader :user
    attr_reader :video_upload_count

    def initialize(payload)
      @favorite_count = payload['favorite_count'].to_i
      @friend_count = payload['friend_count'].to_i
      @user = payload['user'].to_s
      @video_upload_count = payload['video_upload_count'].to_i
    end        
  end

  class Profile
    attr_reader :about_me
    attr_reader :age
    attr_reader :books
    attr_reader :city
    attr_reader :companies
    attr_reader :country
    attr_reader :currently_on
    attr_reader :favorite_video_count
    attr_reader :first_name
    attr_reader :friend_count
    attr_reader :gender
    attr_reader :hobbies
    attr_reader :homepage
    attr_reader :hometown
    attr_reader :last_name
    attr_reader :movies
    attr_reader :occupations
    attr_reader :relationship
    attr_reader :video_upload_count
    attr_reader :video_watch_count

    def initialize(payload)
      @about_me = payload['about_me'].to_s
      @age = payload['age'].to_i
      @books = payload['books'].to_s
      @city = payload['city'].to_s
      @companies = payload['companies'].to_s
      @country = payload['country'].to_s
      @currently_on = YouTube._string_to_boolean(payload['currently_on'])
      @favorite_video_count = payload['favorite_video_count'].to_i
      @first_name = payload['first_name'].to_s
      @friend_count = payload['friend_count'].to_i
      @gender = payload['gender'].to_s
      @hobbies = payload['hobbies'].to_s
      @homepage = payload['homepage'].to_s
      @hometown = payload['hometown'].to_s
      @last_name = payload['last_name'].to_s
      @movies = payload['movies'].to_s
      @occupations = payload['occupations'].to_s
      @relationship = payload['relationship'].to_s
      @video_upload_count = payload['video_upload_count'].to_i
      @video_watch_count = payload['video_watch_count'].to_i
    end
  end

  class Video
    attr_reader :author
    attr_reader :comment_count
    attr_reader :description
    attr_reader :embed_url
    attr_reader :id
    attr_reader :length_seconds
    attr_reader :rating_avg
    attr_reader :rating_count
    attr_reader :tags
    attr_reader :thumbnail_url
    attr_reader :title
    attr_reader :upload_time
    attr_reader :url
    attr_reader :view_count

    def initialize(payload)
      @author = payload['author'].to_s
      @comment_count = payload['comment_count'].to_i
      @description = payload['description'].to_s
      @id = payload['id']
      @length_seconds = payload['length_seconds'].to_i
      @rating_avg = payload['rating_avg'].to_f
      @rating_count = payload['rating_count'].to_i
      @tags = payload['tags']
      @thumbnail_url = payload['thumbnail_url']
      @title = payload['title'].to_s
      @upload_time = YouTube._string_to_time(payload['upload_time'])
      @url = payload['url']
      @view_count = payload['view_count'].to_i

      # the url provided via the API links to the video page -- for
      # convenience, generate the url used to embed in a page
      @embed_url = @url.delete('?').sub('=', '/')
    end    

    # Returns HTML analogous to that provided by the YouTube web site to
    # allow for easy embedding of this video in a web page.  Optional
    # +width+ and +height+ parameters allow specifying the dimensions of
    # the video for display.
    def embed_html(width = 425, height = 350)
      <<edoc
<object width="#{width}" height="#{height}">
  <param name="movie" value="#{embed_url}"></param>
  <param name="wmode" value="transparent"></param>
  <embed src="#{embed_url}" type="application/x-shockwave-flash" 
   wmode="transparent" width="#{width}" height="#{height}"></embed>
</object>
edoc
    end
  end

  class VideoDetails
    attr_reader :author
    attr_reader :channel_list
    attr_reader :comment_list
    attr_reader :description
    attr_reader :length_seconds
    attr_reader :rating_avg
    attr_reader :rating_count
    attr_reader :recording_location
    attr_reader :recording_country
    attr_reader :recording_date
    attr_reader :tags
    attr_reader :thumbnail_url
    attr_reader :title
    attr_reader :update_time
    attr_reader :upload_time
    attr_reader :view_count
    attr_reader :embed_status
    attr_reader :embed_allowed

    def initialize(payload)
      @author = payload['author'].to_s
      @channel_list = payload['channel_list']
      @comment_list = payload['comment_list']
      @description = payload['description'].to_s
      @length_seconds = payload['length_seconds'].to_i
      @rating_avg = payload['rating_avg'].to_f
      @rating_count = payload['rating_count'].to_i
      @recording_country = payload['recording_country'].to_s
      @recording_date = payload['recording_date'].to_s
      @recording_location = payload['recording_location'].to_s
      @tags = payload['tags']
      @thumbnail_url = payload['thumbnail_url']
      @title = payload['title'].to_s
      @update_time = YouTube._string_to_time(payload['update_time'])
      @upload_time = YouTube._string_to_time(payload['upload_time'])
      @view_count = payload['view_count'].to_i
      @embed_status = payload['embed_status']
      @embed_allowed = ( payload['embed_status'] == "ok" )
    end
  end

  private
    # Returns the Ruby boolean object as TrueClass or FalseClass based on
    # the supplied string value.  TrueClass is returned if the value is
    # non-nil and "true" (case-insensitive), else FalseClass is returned.
    def self._string_to_boolean(bool_str)
      (bool_str && bool_str.downcase == "true")
    end

    # Returns a Time object corresponding to the specified time string
    # representing seconds since the epoch, or nil if the string is nil.
    def self._string_to_time(time_str)
      (time_str) ? Time.at(time_str.to_i) : nil
    end    
end
