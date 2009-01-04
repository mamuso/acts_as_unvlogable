Acts as unvlogable
==================

What the hell is this!
----------------------

This is the plugin that we use in [unvlog.com](http://unvlog.com) to manage the supported video services. Is an easy way to obtain a few basics about a video only through its url.

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
        
There is also a method to know where to download the flv.


Install it!
-----------

1. That is a plugin, then you need to do:

        script/plugin install git://github.com/mamuso/acts_as_unvlogable.git
        
2. Optionally you can create the `config/unvlogable.yml` to store keys for the different services. You have in the plugin a [sample file](http://github.com/mamuso/acts_as_unvlogable/tree/master/unvlogable_sample.yml)


And... what else?
-----------------

To know the supported services and particular uses we will do (in a near future :D) a complete documentation in [the wiki](https://github.com/mamuso/acts_as_unvlogable/wikis). 

If you find a bug or want to suggest a new video service, please post us [a ticket](http://tickets.unvlog.com/projects/show/acts-as-unvlogable).

