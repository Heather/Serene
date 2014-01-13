#lang racket/gui
(require net/url net/uri-codec net/sendurl)

(let* ([f (new (class frame% (super-new)
                 (define/augment (on-close)
                   (displayln "Exiting...")))
               [label "Search Serene 1.4"]
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
       
       [duck-search (λ (target)
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
               (make-object button% "Open" zp (λ (btn evt)
                   (send-url (bytes->string/utf-8 
                   (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                   (regexp-match rx str)))))))
               (make-object message% (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                   (regexp-match rx str))))"") zp))))]
       
       [google-search (λ (target)
            (for ([ch (send group-box-panel get-children)])
              (send group-box-panel delete-child ch))
            (for ([str (let* ([g "https://www.google.com/search?q="]
                              [u (string-append g (uri-encode target))]
                              [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
                         (regexp-match* rx (get-pure-port (string->url u))))])
              (let ([zp (new horizontal-panel%
                              [parent group-box-panel]
                              [alignment '(left center)])])
                (make-object button% "Open" zp (λ (btn evt)
                   (send-url (regexp-replace* #px"url[?]q=" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=&amp)"])
                   (regexp-match rx str)))) ""))))
                (make-object message% (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                   (regexp-match rx str)))) "") zp))))]

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
