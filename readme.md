Search Serene
-------------

[![Build Status](https://travis-ci.org/Heather/Serene.png?branch=master)](https://travis-ci.org/Heather/Serene)

Simple stupid search application; my first scheme (racket) experiment based on examples >_<

Applications
------------

 - <b>ss</b> is command line util which can be really cool one day it will become more usable
 - <b>Serene</b> is gui applications with search bar and dynamic buttons (currently) to open links in default browser

Currently
=========

 - Can search on google.com (`-g | --google` on ss [default])
 - Can search on duckduckgo (`-d | --doge` on ss)
 - Automatically avoid advertising / promoted results

<b>ss</b> (command line util)

 - Numbering search result (and sure display it)
 - Save search result in temporary file
 - Open (with -o) result by number (`ss racket & ss -o 1`)

TODO
----

 - Save more result and use paging somehow
 
``` racket
[duck-search 
    (serene "https://duckduckgo.com/html/?q="
            #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"
            1 11
            (? (str) (bytes->string/utf-8 
                      (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                             (regexp-match rx str)))))
            (? (str) (regexp-replace* #px"</?b>" 
                        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                                (regexp-match rx str))))"")))]
```

Does it work?
=============

foshizzlemanizzle
