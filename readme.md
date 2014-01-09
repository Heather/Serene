Search Serene
-------------

Simple stupid search application; my first scheme (racket) experiment based on examples >_<

``` racket
(define (let-me-google-that-for-you str)
  (let* ([g "https://www.google.com/search?q="]
         [u (string-append g (uri-encode str))]
         [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
    (regexp-match* rx (get-pure-port (string->url u)))))
(define (postparse strs)
  
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  
  (for ([str strs])
    (define zp (new horizontal-panel%
               [parent group-box-panel]
               [alignment '(left center)]))
    
    ;(displayln str) #| DEBUG |#
    (define link
      (regexp-replace* #px"url[?]q=" 
      (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=\">)"])
                         (regexp-match rx str)))) ""))
    (define lbl
      (regexp-replace* #px"</?b>" 
        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                         (regexp-match rx str)))) ""))
    (make-object button% "Open" zp (? (btn evt)
             (send-url link)
           #|(message-box "link" link)|#)) #| DEBUG |#
    (make-object message% lbl zp)))
```
