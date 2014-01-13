Search Serene
-------------

Simple stupid search application; my first scheme (racket) experiment based on examples >_<

Currently
=========

 - Can search on google.com
 - Can search on duckduckgo

``` racket
[duck-search (? (target)
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  (for ([str (let* ([g "https://duckduckgo.com/html/?q="]
                    [u (string-append g (uri-encode target))]
                    [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"])
               (regexp-match* rx (get-pure-port (string->url u))))]
        [i (in-naturals 1)]
        #:when (< i 14)) ; Just to show as much as Google
    (let ([zp (new horizontal-panel%
                    [parent group-box-panel]
                    [alignment '(left center)])])
       (make-object button% "Open" zp (? (btn evt)
           (send-url (bytes->string/utf-8 
           (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
           (regexp-match rx str)))))))
       (make-object message% (regexp-replace* #px"</?b>" 
           (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
           (regexp-match rx str))))"") zp))))]
```
