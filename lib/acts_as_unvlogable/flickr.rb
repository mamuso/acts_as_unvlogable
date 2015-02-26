# included here to skip the gem dependency and modified to manage video capabilities.
# this is the updated version from http://github.com/ctagg/flickr/tree/master/lib/flickr.rb
# Modified and simplified to keep only the used methods

require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'digest/md5'

# Flickr client class. Requires an API key
class Flickr
  attr_reader :api_key, :auth_token
  attr_accessor :user
  
  HOST_URL = 'https://flickr.com'
  API_PATH = '/services/rest'

  # Flickr, annoyingly, uses a number of representations to specify the size 
  # of a photo, depending on the context. It gives a label such a "Small" or
  # "Medium" to a size of photo, when returning all possible sizes. However, 
  # when generating the uri for the page that features that size of photo, or
  # the source url for the image itself it uses a single letter. Bizarrely, 
  # these letters are different depending on whether you want the Flickr page
  # for the photo or the source uri -- e.g. a "Small" photo (240 pixels on its
  # longest side) may be viewed at 
  # "http://www.flickr.com/photos/sco/2397458775/sizes/s/"
  # but its source is at 
  # "http://farm4.static.flickr.com/3118/2397458775_2ec2ddc324_m.jpg". 
  # The VALID_SIZES hash associates the correct letter with a label
  VALID_SIZES = { "Square" => ["s", "sq"],
                  "Thumbnail" => ["t", "t"],
                  "Small" => ["m", "s"],
                  "Medium" => [nil, "m"],
                  "Large" => ["b", "l"]
                }

  # To use the Flickr API you need an api key 
  # (see http://www.flickr.com/services/api/misc.api_keys.html), and the flickr 
  # client object shuld be initialized with this. You'll also need a shared
  # secret code if you want to use authentication (e.g. to get a user's
  # private photos)
  # There are two ways to initialize the Flickr client. The preferred way is with
  # a hash of params, e.g. 'api_key' => 'your_api_key', 'shared_secret' => 
  # 'shared_secret_code'. The older (deprecated) way is to pass an ordered series of 
  # arguments. This is provided for continuity only, as several of the arguments
  # are no longer usable ('email', 'password')
  def initialize(api_key_or_params=nil, email=nil, password=nil, shared_secret=nil)
    @host = HOST_URL
    @api = API_PATH
    if api_key_or_params.is_a?(Hash)
      @api_key = api_key_or_params['api_key']
      @shared_secret = api_key_or_params['shared_secret']
      @auth_token = api_key_or_params['auth_token']
    else
      @api_key = api_key_or_params
      @shared_secret = shared_secret
      login(email, password) if email and password
    end
  end

    
  # Implements everything else.
  # Any method not defined explicitly will be passed on to the Flickr API,
  # and return an XmlSimple document. For example, Flickr#test_echo is not 
  # defined, so it will pass the call to the flickr.test.echo method.
  def method_missing(method_id, params={})
    request(method_id.id2name.gsub(/_/, '.'), params)
  end

  # Takes a Flickr API method name and set of parameters; returns an XmlSimple object with the response
  def request(method, params={})
    url = request_url(method, params)
    response = XmlSimple.xml_in(open(url), { 'ForceArray' => false })
    raise response['err']['msg'] if response['stat'] != 'ok'
    response
  end
  
  # Builds url for Flickr API REST request from given the flickr method name 
  # (exclusing the 'flickr.' that begins each method call) and params (where
  # applicable) which should be supplied as a Hash (e.g 'user_id' => "foo123")
  def request_url(method, params={})
    method = 'flickr.' + method
    url = "#{@host}#{@api}/?api_key=#{@api_key}&method=#{method}"
    params.merge!('api_key' => @api_key, 'method' => method, 'auth_token' => @auth_token)
    signature = signature_from(params) 
    
    url = "#{@host}#{@api}/?" + params.merge('api_sig' => signature).collect { |k,v| "#{k}=" + CGI::escape(v.to_s) unless v.nil? }.compact.join("&")
  end
  
  def signature_from(params={})
    return unless @shared_secret # don't both getting signature if no shared_secret
    request_str = params.reject {|k,v| v.nil?}.collect {|p| "#{p[0].to_s}#{p[1]}"}.sort.join # build key value pairs, sort in alpha order then join them, ignoring those with nil value
    return Digest::MD5.hexdigest("#{@shared_secret}#{request_str}")
  end
  
  # A collection of photos is returned as a PhotoCollection, a subclass of Array.
  # This allows us to retain the pagination info returned by Flickr and make it
  # accessible in a friendly way
  class PhotoCollection < Array
    attr_reader :page, :pages, :perpage, :total
    
    # builds a PhotoCollection from given params, such as those returned from 
    # photos.search API call
    def initialize(photos_api_response={}, api_key=nil)
    end
  end
  
  # Todo:
  # logged_in?
  # if logged in:
  # flickr.blogs.getList
  # flickr.favorites.add
  # flickr.favorites.remove
  # flickr.groups.browse
  # flickr.photos.getCounts
  # flickr.photos.getNotInSet
  # flickr.photos.getUntagged
  # flickr.photosets.create
  # flickr.photosets.orderSets
  # flickr.tags.getListUserPopular
  # flickr.test.login
  # uploading
  class User
    
    attr_reader :client, :id, :name, :location, :photos_url, :url, :count, :firstdate, :firstdatetaken

    # A Flickr::User can be instantiated in two ways. The old (deprecated) 
    # method is with an ordered series of values. The new method is with a 
    # params Hash, which is easier when a variable number of params are 
    # supplied, which is the case here, and also avoids having to constantly
    # supply nil values for the email and password, which are now irrelevant
    # as authentication is no longer done this way. 
    # An associated flickr client will also be generated if an api key is 
    # passed among the arguments or in the params hash. Alternatively, and
    # most likely, an existing client object may be passed in the params hash 
    # (e.g. 'client' => some_existing_flickr_client_object), and this is
    # what happends when users are initlialized as the result of a method 
    # called on the flickr client (e.g. flickr.users)
    def initialize(id_or_params_hash=nil, username=nil, email=nil, password=nil, api_key=nil)
      if id_or_params_hash.is_a?(Hash)
        id_or_params_hash.each { |k,v| self.instance_variable_set("@#{k}", v) } # convert extra_params into instance variables
      else
        @id = id_or_params_hash
        @username = username
        @email = email
        @password = password
        @api_key = api_key
      end
      @client ||= Flickr.new('api_key' => @api_key, 'shared_secret' => @shared_secret, 'auth_token' => @auth_token) if @api_key
      @client.login(@email, @password) if @email and @password # this is now irrelevant as Flickr API no longer supports authentication this way
    end

  end

  class Photo

    attr_reader :id, :client, :title

    def initialize(id=nil, api_key=nil, extra_params={})
      @id = id
      @api_key = api_key
      extra_params.each { |k,v| self.instance_variable_set("@#{k}", v) } # convert extra_params into instance variables
      @client = Flickr.new @api_key
    end
        
    def title
      @title.nil? ? getInfo("title") : @title
    end
    
    # converts string or symbol size to a capitalized string
    def normalize_size(size)
      size ? size.to_s.capitalize : size
    end

    # Returns the URL for the image (default or any specified size)
    def source(size='Medium')
      image_source_uri_from_self(size) || sizes(size)['source']
    end
    
    # unvlog
    def media
      @media || getInfo("media")
    end
    
    def secret
      @secret || getInfo("secret")
    end
    
    
    private

      # Implements flickr.photos.getInfo
      def getInfo(attrib="")
        return instance_variable_get("@#{attrib}") if @got_info
        info = @client.photos_getInfo('photo_id'=>@id)['photo']
        @got_info = true
        info.each { |k,v| instance_variable_set("@#{k}", v)}
        @media = info['media']
        @secret = info['secret']
        @owner = User.new(info['owner']['nsid'], info['owner']['username'], nil, nil, @api_key)
        @tags = info['tags']['tag']
        @notes = info['notes']['note']#.collect { |note| Note.new(note.id) }
        @url = info['urls']['url']['content'] # assumes only one url
        instance_variable_get("@#{attrib}")
      end
      
      # Builds source uri of image from params (often returned from other 
      # methods, e.g. User#photos). As specified at: 
      # http://www.flickr.com/services/api/misc.urls.html. If size is given 
      # should be one the keys in the VALID_SIZES hash, i.e.
      # "Square", "Thumbnail", "Medium", "Large", "Original", "Small" (These
      # are the values returned by flickr.photos.getSizes).
      # If no size is given the uri for "Medium"-size image, i.e. with width
      # of 500 is returned
      # TODO: Handle "Original" size
      def image_source_uri_from_self(size=nil)
        return unless @farm&&@server&&@id&&@secret
        s_size = VALID_SIZES[normalize_size(size)] # get the short letters array corresponding to the size
        s_size = s_size&&s_size[0] # the first element of this array is used to build the source uri
        if s_size.nil?
          "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}.jpg"
        else
          "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}_#{s_size}.jpg"
        end
      end
      
  end
  
end
