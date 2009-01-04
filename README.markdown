Acts as unvlogable
==================

What the hell is this!
----------------------

This is the plugin that we use in [unvlog.com](http://unvlog.com) to manage the supported video services. It is an easy way to obtain a few basics about a video only through its url.

A quick example:

To include [this video](http://www.youtube.com/watch?v=GPQnbtldFyo) in [this post](http://unvlog.com/blat/2008/3/10/otro-pelotazo) we need to know its title, the correct way to embed it and its thumbnail url. With this plugin we have an easy access to this data:

        @aha = UnvlogIt.new("http://www.youtube.com/watch?v=GPQnbtldFyo")
        @aha.title => "paradon del portero"
        @aha.thumbnail => "http://i4.ytimg.com/vi/GPQnbtldFyo/default.jpg"
        @aha.embed_url => "http://www.youtube.com/v/GPQnbtldFyo"
        @aha.embed_html(width, height) => "<object [...]</object>"
        @aha.flv => "http://...flv"
        # all together :)
        @aha.video_details(width, height) => {
                                                :title => ...,
                                                :thumbnail => ...,
                                                :embed_url => ...,
                                                :embed_html => ...,
                                                :flv => ...
                                              }
        
With this plugin we have an unique way to manage multiple services :)


Install it!
-----------

1. That is a plugin, then you need to do:

        script/plugin install git://github.com/mamuso/acts_as_unvlogable.git
        
2. Optionally you can create the `config/unvlogable.yml` to store keys for the different services. You have in the plugin a [sample file](http://github.com/mamuso/acts_as_unvlogable/tree/master/unvlogable_sample.yml)


Use it!
-------


The idea is make it as simple as possible. For a given video URL as <http://vimeo.com/1785993>:

        videotron = UnvlogIt.new("http://vimeo.com/1785993")

Then we have methods to know the 'basics' for use this video on your application.

-   __title:__ A method to know the title of the video on the service.
  
          videotron.title
          => "Beached"

-   __thumbnail:__ An image representation of the video. Each service has a different size, but... it works :)

          videotron.thumbnail
          => "http://bc1.vimeo.com/vimeo/thumbs/143104745_640.jpg"

-   __embed\_url:__ The url (with flashvars) of the video player.

          videotron.embed_url
          => "http://vimeo.com/moogaloop.swf?clip_id=1785993 [...] &show_portrait=1"

-   __embed\_html(width, height):__ Uses the embed\_url to build an oembed string. The default width x height is 425 x 344, but we can specify a different one.

          videotron.embed_html(400, 300)
          => "<object width='400' height='300'><param name='mo [...] 300'></embed></object>"

-   __flv:__ Gets the flv url. In this edition we implement this method in all the services, but is possible that we can't get the flv in some scenarios. Remember that in some services the flv url expires and in most of their terms don't allow use the flv without its player.

          videotron.flv
          => "http://www.vimeo.com/moogaloop/play/clip:1785993/ [...] 8ee400/video.flv"

-   __video\_details(width, height):__ All together :), returns all the previous elements in a hash. Width and height can be specified to build the embed\_html.

          videotron.video_details
          => "{ [...] }"


Supported services
------------------

At this moment we support the following video services:

-   [Youtube](http://www.youtube.com/)
-   [Google video](http://video.google.com/)
-   [Vimeo](http://vimeo.com/)
-   [Flickr (videos)](http://flickr.com/)
-   [Metacafe](http://metacafe.com/)
-   [Dailymotion](http://dailymotion.com/)
-   [Collegehumor](http://collegehumor.com/)
-   [Blip.tv](http://blip.tv/)
-   [Myspace](http://vids.myspace.com/)
-   [Ted Talks](http://www.ted.com/talks/)
-   [11870.com](http://11870.com/)
-   [Qik](http://qik.com/)
-   [Marca.tv](http://www.marca.tv/)
-   [Dalealplay](http://www.dalealplay.com/)

We are always open to incude new services.

And... what else?
-----------------
If you find a bug or want to suggest a new video service, please tell it to us in [a ticket](http://tickets.unvlog.com/projects/show/acts-as-unvlogable).

Thanks!!
