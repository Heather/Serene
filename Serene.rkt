#lang racket/gui
(require net/url net/uri-codec net/sendurl)

(define f (new (class frame% (super-new)
        (define/augment (on-close)
          (displayln "Exiting...")))
      [label "Search Serene 1.2"]
      [min-width 350]))

(define lmgfy (new text-field%
                   [label "Search"]
                   [parent f]
                   [init-value ""]))

(define group-box-panel (new group-box-panel%
                             [parent f]
                             [label "Search results"]
                             [min-width 100]
                             [min-height 300]))

(define (google-search target)
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  (for ([str (let* ([g "https://www.google.com/search?q="]
                    [u (string-append g (uri-encode target))]
                    [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
               (regexp-match* rx (get-pure-port (string->url u))))])
    (define zp (new horizontal-panel%
               [parent group-box-panel]
               [alignment '(left center)]))
    (make-object button% "Open" zp (λ (btn evt)
             (send-url (regexp-replace* #px"url[?]q=" 
      (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=\" ?>)"])
                         (regexp-match rx str)))) ""))))
    (make-object message% (regexp-replace* #px"</?b>" 
        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                         (regexp-match rx str)))) "") zp)))

(define (duck-search target)
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  (for ([str (let* ([g "https://duckduckgo.com/html/?q="]
                    [u (string-append g (uri-encode target))]
                    [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"])
               (regexp-match* rx (get-pure-port (string->url u))))]
        [i (in-naturals 1)]
        #:when (< i 14)) ; Just to show as much as Google
    (define zp (new horizontal-panel%
               [parent group-box-panel]
               [alignment '(left center)]))
    (displayln str)
    (make-object button% "Open" zp (λ (btn evt)
             (send-url (bytes->string/utf-8 
                       (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                         (regexp-match rx str)))))))
    (make-object message% (regexp-replace* #px"</?b>" 
        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                         (regexp-match rx str)))) "") zp)))

(define p (new horizontal-panel%
               [parent f]
               [alignment '(right top)]))
(define google (new button%
                    [parent p]
                    [label "Google"]
                    [callback (λ (btn evt)
     (google-search (send lmgfy get-value)))]))
(define duck (new button%
                  [parent p]
                  [label "DuckDuckGo"]
                  [callback (λ (btn evt)
     (duck-search (send lmgfy get-value)))]))
(define about (new button%
                    [parent p]
                    [label "About"]
                    [callback (λ (btn evt)
     (message-box "Search Serene" "  Search Serene by Heather  "))]))

(send f show #t)
