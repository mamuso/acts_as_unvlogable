# included here to skip the gem dependency and modified to manage video capabilities.
# this is the updated version from http://github.com/ctagg/flickr/tree/master/lib/flickr.rb

# = Flickr
#   An insanely easy interface to the Flickr photo-sharing service. By Scott Raymond.
#   
# Author::    Scott Raymond <sco@redgreenblu.com>
# Copyright:: Copyright (c) 2005 Scott Raymond <sco@redgreenblu.com>. Additional content by Patrick Plattes and Chris Taggart (http://pushrod.wordpress.com)
# License::   MIT <http://www.opensource.org/licenses/mit-license.php>
#
# BASIC USAGE:
#  require 'flickr'
#  flickr = Flickr.new('some_flickr_api_key')    # create a flickr client (get an API key from http://www.flickr.com/services/api/)
#  user = flickr.users('sco@scottraymond.net')   # lookup a user
#  user.name                                     # get the user's name
#  user.location                                 # and location
#  user.photos                                   # grab their collection of Photo objects...
#  user.groups                                   # ...the groups they're in...
#  user.contacts                                 # ...their contacts...
#  user.favorites                                # ...favorite photos...
#  user.photosets                                # ...their photo sets...
#  user.tags                                     # ...and their tags
#  recentphotos = flickr.photos                  # get the 100 most recent public photos
#  photo = recentphotos.first                    # or very most recent one
#  photo.url                                     # see its URL,
#  photo.title                                   # title,
#  photo.description                             # and description,
#  photo.owner                                   # and its owner.
#  File.open(photo.filename, 'w') do |file|
#    file.puts p.file                            # save the photo to a local file
#  end
#  flickr.photos.each do |p|                     # get the last 100 public photos...
#    File.open(p.filename, 'w') do |f|
#      f.puts p.file('Square')                   # ...and save a local copy of their square thumbnail
#    end
#  end


require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'digest/md5'

# Flickr client class. Requires an API key
class Flickr
  attr_reader :api_key, :auth_token
  attr_accessor :user
  
  HOST_URL = 'http://flickr.com'
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

  # Gets authentication token given a Flickr frob, which is returned when user
  # allows access to their account for the application with the api_key which
  # made the request
  def get_token_from(frob)
    auth_response = request("auth.getToken", :frob => frob)['auth']
    @auth_token = auth_response['token']
    @user = User.new( 'id' => auth_response['user']['nsid'], 
                      'username' => auth_response['user']['username'],
                      'name' => auth_response['user']['fullname'],
                      'client' => self)
    @auth_token
  end
  
  # Stores authentication credentials to use on all subsequent calls.
  # If authentication succeeds, returns a User object.
  # NB This call is no longer in API and will result in an error if called
  def login(email='', password='')
    @email = email
    @password = password
    user = request('test.login')['user'] rescue fail
    @user = User.new(user['id'], nil, nil, nil, @api_key)
  end
  
  # Implements flickr.urls.lookupGroup and flickr.urls.lookupUser
  def find_by_url(url)
    response = urls_lookupUser('url'=>url) rescue urls_lookupGroup('url'=>url) rescue nil
    (response['user']) ? User.new(response['user']['id'], nil, nil, nil, @api_key) : Group.new(response['group']['id'], @api_key) unless response.nil?
  end

  # Implements flickr.photos.getRecent and flickr.photos.search
  def photos(*criteria)
    criteria ? photos_search(*criteria) : recent
  end

  # flickr.photos.getRecent
  # 100 newest photos from everyone
  def recent
    photos_request('photos.getRecent')
  end
  
  def photos_search(params={})
    photos_request('photos.search', params)
  end
  alias_method :search, :photos_search
  
  # Gets public photos with a given tag
  def tag(tag)
    photos('tags'=>tag)
  end
  
  # Implements flickr.people.findByEmail and flickr.people.findByUsername. 
  def users(lookup=nil)
    user = people_findByEmail('find_email'=>lookup)['user'] rescue people_findByUsername('username'=>lookup)['user']
    return User.new("id" => user["nsid"], "username" => user["username"], "client" => self)
  end

  # Implements flickr.groups.search
  def groups(group_name, options={})
    collection = groups_search({"text" => group_name}.merge(options))['groups']['group']
    collection = [collection] if collection.is_a? Hash
    
    collection.collect { |group| Group.new( "id" => group['nsid'], 
                                            "name" => group['name'], 
                                            "eighteenplus" => group['eighteenplus'],
                                            "client" => self) }
  end
  
  # Implements flickr.tags.getRelated
  def related_tags(tag)
    tags_getRelated('tag'=>tag)['tags']['tag']
  end
  
  # Implements flickr.photos.licenses.getInfo
  def licenses
    photos_licenses_getInfo['licenses']['license']
  end
  
  # Returns url for user to login in to Flickr to authenticate app for a user
  def login_url(perms)
    "http://flickr.com/services/auth/?api_key=#{@api_key}&perms=#{perms}&api_sig=#{signature_from('api_key'=>@api_key, 'perms' => perms)}"
  end
    
  # Implements everything else.
  # Any method not defined explicitly will be passed on to the Flickr API,
  # and return an XmlSimple document. For example, Flickr#test_echo is not 
  # defined, so it will pass the call to the flickr.test.echo method.
  def method_missing(method_id, params={})
    request(method_id.id2name.gsub(/_/, '.'), params)
  end

  # Does an HTTP GET on a given URL and returns the response body
  def http_get(url)
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end

  # Takes a Flickr API method name and set of parameters; returns an XmlSimple object with the response
  def request(method, params={})
    url = request_url(method, params)
    response = XmlSimple.xml_in(http_get(url), { 'ForceArray' => false })
    raise response['err']['msg'] if response['stat'] != 'ok'
    response
  end

  # acts like request but returns a PhotoCollection (a list of Photo objects)
  def photos_request(method, params={})
    photos = request(method, params)
    PhotoCollection.new(photos, @api_key)
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
      [ "page", "pages", "perpage", "total" ].each { |i| instance_variable_set("@#{i}", photos_api_response["photos"][i])} 
      collection = photos_api_response['photos']['photo'] || []
      collection = [collection] if collection.is_a? Hash
      collection.each { |photo| self << Photo.new(photo.delete('id'), api_key, photo) }
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

    def username
      @username.nil? ? getInfo.username : @username
    end
    def name
      @name.nil? ? getInfo.name : @name
    end
    def location
      @location.nil? ? getInfo.location : @location
    end
    def count
      @count.nil? ? getInfo.count : @count
    end
    def firstdate
      @firstdate.nil? ? getInfo.firstdate : @firstdate
    end
    def firstdatetaken
      @firstdatetaken.nil? ? getInfo.firstdatetaken : @firstdatetaken
    end
    
    # Builds url for user's photos page as per 
    # http://www.flickr.com/services/api/misc.urls.html
    def photos_url
      "http://www.flickr.com/photos/#{id}/"
    end
        
    # Builds url for user's profile page as per 
    # http://www.flickr.com/services/api/misc.urls.html
    def url
      "http://www.flickr.com/people/#{id}/"
    end
    
    def pretty_url
      @pretty_url ||= @client.urls_getUserProfile('user_id'=>@id)['user']['url']
    end
    
    # Implements flickr.people.getPublicGroups
    def groups
      collection = @client.people_getPublicGroups('user_id'=>@id)['groups']['group']
      collection = [collection] if collection.is_a? Hash
      collection.collect { |group| Group.new( "id" => group['nsid'], 
                                           "name" => group['name'],
                                           "eighteenplus" => group['eighteenplus'],
                                           "client" => @client) }
    end
    
    # Implements flickr.people.getPublicPhotos. Options hash allows you to add
    # extra restrictions as per flickr.people.getPublicPhotos docs, e.g. 
    # user.photos('per_page' => '25', 'extras' => 'date_taken')
    def photos(options={})
      @client.photos_request('people.getPublicPhotos', {'user_id' => @id}.merge(options))
      # what about non-public photos?
    end

    # Gets photos with a given tag
    def tag(tag)
      @client.photos('user_id'=>@id, 'tags'=>tag)
    end

    # Implements flickr.contacts.getPublicList and flickr.contacts.getList
    def contacts
      @client.contacts_getPublicList('user_id'=>@id)['contacts']['contact'].collect { |contact| User.new(contact['nsid'], contact['username'], nil, nil, @api_key) }
      #or
    end
    
    # Implements flickr.favorites.getPublicList
    def favorites
      @client.photos_request('favorites.getPublicList', 'user_id' => @id)
    end
    
    # Implements flickr.photosets.getList
    def photosets
      @client.photosets_getList('user_id'=>@id)['photosets']['photoset'].collect { |photoset| Photoset.new(photoset['id'], @api_key) }
    end

    # Implements flickr.tags.getListUser
    def tags
      @client.tags_getListUser('user_id'=>@id)['who']['tags']['tag'].collect { |tag| tag }
    end

    # Implements flickr.photos.getContactsPublicPhotos and flickr.photos.getContactsPhotos
    def contactsPhotos
      @client.photos_request('photos.getContactsPublicPhotos', 'user_id' => @id)
    end
    
    def to_s
      @name
    end
    
    

    private

      # Implements flickr.people.getInfo, flickr.urls.getUserPhotos, and flickr.urls.getUserProfile
      def getInfo
        info = @client.people_getInfo('user_id'=>@id)['person']
        @username = info['username']
        @name = info['realname']
        @location = info['location']
        @count = info['photos']['count']
        @firstdate = info['photos']['firstdate']
        @firstdatetaken = info['photos']['firstdatetaken']
        self
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
    
    # Allows access to all photos instance variables through hash like 
    # interface, e.g. photo["datetaken"] returns @datetaken instance 
    # variable. Useful for accessing any weird and wonderful parameter
    # that may have been returned by Flickr when finding the photo,
    # e.g. those returned by the extras argument in 
    # flickr.people.getPublicPhotos
    def [](param_name)
      instance_variable_get("@#{param_name}")
    end
    
    def title
      @title.nil? ? getInfo("title") : @title
    end
    
    # Returns the owner of the photo as a Flickr::User. If we have no info 
    # about the owner, we make an API call to get it. If we already have
    # the owner's id, create a user based on that. Either way, we cache the
    # result so we don't need to check again
    def owner
      case @owner
      when Flickr::User
        @owner
      when String
        @owner = Flickr::User.new(@owner, nil, nil, nil, @api_key)
      else
        getInfo("owner")
      end
    end

    def server
      @server.nil? ? getInfo("server") : @server
    end

    def isfavorite
      @isfavorite.nil? ? getInfo("isfavorite") : @isfavorite
    end

    def license
      @license.nil? ? getInfo("license") : @license
    end

    def rotation
      @rotation.nil? ? getInfo("rotation") : @rotation
    end

    def description
      @description || getInfo("description")
    end

    def notes
      @notes.nil? ? getInfo("notes") : @notes
    end

    # Returns the URL for the photo size page
    # defaults to 'Medium'
    # other valid sizes are in the VALID_SIZES hash
    def size_url(size='Medium')
      uri_for_photo_from_self(size) || sizes(size)['url']
    end

    # converts string or symbol size to a capitalized string
    def normalize_size(size)
      size ? size.to_s.capitalize : size
    end

    # the URL for the main photo page
    # if getInfo has already been called, this will return the pretty url
    #
    # for historical reasons, an optional size can be given
    # 'Medium' returns the regular url; any other size returns a size page
    # use size_url instead
    def url(size = nil)
      if normalize_size(size) != 'Medium'
        size_url(size)
      else
        @url || uri_for_photo_from_self
      end
    end

    # the 'pretty' url for a photo
    # (if the user has set up a custom name)
    # eg, http://flickr.com/photos/granth/2584402507/ instead of
    #     http://flickr.com/photos/23386158@N00/2584402507/
    def pretty_url
      @url || getInfo("pretty_url")
    end

    # Returns the URL for the image (default or any specified size)
    def source(size='Medium')
      image_source_uri_from_self(size) || sizes(size)['source']
    end

    # Returns the photo file data itself, in any specified size. Example: File.open(photo.title, 'w') { |f| f.puts photo.file }
    def file(size='Medium')
      Net::HTTP.get_response(URI.parse(source(size))).body
    end

    # Unique filename for the image, based on the Flickr NSID
    def filename
      "#{@id}.jpg"
    end

    # Implements flickr.photos.getContext
    def context
      context = @client.photos_getContext('photo_id'=>@id)
      @previousPhoto = Photo.new(context['prevphoto'].delete('id'), @api_key, context['prevphoto']) if context['prevphoto']['id']!='0'
      @nextPhoto = Photo.new(context['nextphoto'].delete('id'), @api_key, context['nextphoto']) if context['nextphoto']['id']!='0'
      return [@previousPhoto, @nextPhoto]
    end

    # Implements flickr.photos.getExif
    def exif
      @client.photos_getExif('photo_id'=>@id)['photo']
    end

    # Implements flickr.photos.getPerms
    def permissions
      @client.photos_getPerms('photo_id'=>@id)['perms']
    end

    # Implements flickr.photos.getSizes
    def sizes(size=nil)
      size = normalize_size(size)
      sizes = @client.photos_getSizes('photo_id'=>@id)['sizes']['size']
      sizes = sizes.find{|asize| asize['label']==size} if size
      return sizes
    end

    # flickr.tags.getListPhoto
    def tags
      @client.tags_getListPhoto('photo_id'=>@id)['photo']['tags']
    end

    # Implements flickr.photos.notes.add
    def add_note(note)
    end
    
    # Implements flickr.photos.setDates
    def dates=(dates)
    end

    # Implements flickr.photos.setPerms
    def perms=(perms)
    end
    
    # Implements flickr.photos.setTags
    def tags=(tags)
    end
    
    # Implements flickr.photos.setMeta
    def title=(title)
    end
    def description=(title)
    end

    # Implements flickr.photos.addTags
    def add_tag(tag)
    end
    
    # Implements flickr.photos.removeTag
    def remove_tag(tag)
    end

    # Implements flickr.photos.transform.rotate
    def rotate
    end

    # Implements flickr.blogs.postPhoto
    def postToBlog(blog_id, title='', description='')
      @client.blogs_postPhoto('photo_id'=>@id, 'title'=>title, 'description'=>description)
    end

    # Implements flickr.photos.notes.delete
    def deleteNote(note_id)
    end

    # Implements flickr.photos.notes.edit
    def editNote(note_id)
    end
        
    # Converts the Photo to a string by returning its title
    def to_s
      title
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
      
      # Builds uri of Flickr page for photo. By default returns the main 
      # page for the photo, but if passed a size will return the simplified
      # flickr page featuring the given size of the photo
      # TODO: Handle "Original" size
      def uri_for_photo_from_self(size=nil)
        return unless @owner&&@id
        size = normalize_size(size)
        s_size = VALID_SIZES[size] # get the short letters array corresponding to the size
        s_size = s_size&&s_size[1] # the second element of this array is used to build the uri of the flickr page for this size
        "http://www.flickr.com/photos/#{owner.id}/#{@id}" + (s_size ? "/sizes/#{s_size}/" : "")
      end
  end

  # Todo:
  # flickr.groups.pools.add
  # flickr.groups.pools.getContext
  # flickr.groups.pools.getGroups
  # flickr.groups.pools.getPhotos
  # flickr.groups.pools.remove
  class Group
    attr_reader :id, :client, :description, :name, :eighteenplus, :members, :online, :privacy, :url#, :chatid, :chatcount
    
    def initialize(id_or_params_hash=nil, api_key=nil)
      if id_or_params_hash.is_a?(Hash)
        id_or_params_hash.each { |k,v| self.instance_variable_set("@#{k}", v) } # convert extra_params into instance variables
      else
        @id = id_or_params_hash
        @api_key = api_key      
        @client = Flickr.new @api_key
      end
    end

    # Implements flickr.groups.getInfo and flickr.urls.getGroup
    # private, once we can call it as needed
    def getInfo
      info = @client.groups_getInfo('group_id'=>@id)['group']
      @name = info['name']
      @members = info['members']
      @online = info['online']
      @privacy = info['privacy']
      # @chatid = info['chatid']
      # @chatcount = info['chatcount']
      @url = @client.urls_getGroup('group_id'=>@id)['group']['url']
      self
    end

  end

  # Todo:
  # flickr.photosets.delete
  # flickr.photosets.editMeta
  # flickr.photosets.editPhotos
  # flickr.photosets.getContext
  # flickr.photosets.getInfo
  # flickr.photosets.getPhotos
  class Photoset

    attr_reader :id, :client, :owner, :primary, :photos, :title, :description, :url

    def initialize(id=nil, api_key=nil)
      @id = id
      @api_key = api_key
      @client = Flickr.new @api_key
    end

    # Implements flickr.photosets.getInfo
    # private, once we can call it as needed
    def getInfo
      info = @client.photosets_getInfo('photoset_id'=>@id)['photoset']
      @owner = User.new(info['owner'], nil, nil, nil, @api_key)
      @primary = info['primary']
      @photos = info['photos']
      @title = info['title']
      @description = info['description']
      @url = "http://www.flickr.com/photos/#{@owner.getInfo.username}/sets/#{@id}/"
      self
    end

  end
  
end
