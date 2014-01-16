#lang racket/gui
(require net/url net/uri-codec net/sendurl)

(let* ([f (new (class frame% (super-new)
                 (define/augment (on-close)
                   (displayln "Exiting...")))
               [label "Search Serene 1.7"]
               [min-width 350])]
       [lmgfy (new text-field%
                   [label "Search"]
                   [parent f]
                   [init-value ""])]
       [group-box-panel (new group-box-panel%
                             [parent f]
                             [label "Search results"]
                             [min-width 100]
                             [min-height 300])]
       
       [serene (λ (base baserx i0 i1 getHttp getDescription)
                 (λ (target)
                   (for ([str (let ([u (string-append base (uri-encode target))])
                                (regexp-match* baserx (get-pure-port (string->url u))))]
                         [i (in-naturals 1)]
                         #:when (and (< i i1) (> i i0)))
                     (let ([zp (new horizontal-panel%
                                    [parent group-box-panel]
                                    [alignment '(left center)])])
                       (make-object button% "Open" zp (λ (btn evt) (send-url (getHttp str))))
                       (make-object message% (getDescription str) zp)))))]
       
       [duck-search (serene "https://duckduckgo.com/html/?q="
                            #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"
                            1 11
                            (λ (str) (bytes->string/utf-8 
                                      (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                                             (regexp-match rx str)))))
                            (λ (str) (regexp-replace* #px"</?b>" 
                                                      (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                                                                                  (regexp-match rx str))))"")))]
       
       [google-search (serene "https://www.google.com/search?q="
                              #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"
                              0 11
                              (λ (str) (regexp-replace* #px"url[?]q=" 
                                                        (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=&amp)"])
                                                                                    (regexp-match rx str)))) ""))
                              (λ (str) (regexp-replace* #px"</?b>" 
                                                        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                                                                                    (regexp-match rx str)))) "")))]
       
       [p (new horizontal-panel%
               [parent f]
               [alignment '(right top)])]

       [duck (new button%
                  [parent p]
                  [label "DuckDuckGo"]
                  [callback (λ (btn evt)
           (duck-search (send lmgfy get-value)))])]
       [google (new button%
                    [parent p]
                    [label "Google"]
                    [callback (λ (btn evt)
           (google-search (send lmgfy get-value)))])]

       [about (new button%
                   [parent p]
                   [label "About"]
                   [callback (λ (btn evt)
           (message-box "Search Serene" "  Search Serene by Heather  "))])])

(send f show #t))
