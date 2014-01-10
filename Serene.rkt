#lang racket/gui
(require net/url net/uri-codec net/sendurl)

(define f (new (class frame% (super-new)
        (define/augment (on-close)
          (displayln "Exiting...")))
      [label "Search Serene 1.1"]
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

(define (let-me-google-that-for-you str)
  (let* ([g "https://www.google.com/search?q="]
         [u (string-append g (uri-encode str))]
         [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
    (regexp-match* rx (get-pure-port (string->url u)))))
(define (let-me-duck-that-for-you str)
  (let* ([g "https://duckduckgo.com/html/?q="]
         [u (string-append g (uri-encode str))]
         [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a)"])
    (regexp-match* rx (get-pure-port (string->url u)))))

(define (postparse strs)
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  (for ([str strs])
    (define zp (new horizontal-panel%
               [parent group-box-panel]
               [alignment '(left center)]))
    (define link
      (regexp-replace* #px"url[?]q=" 
      (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=\" ?>)"])
                         (regexp-match rx str)))) ""))
    (define lbl
      (regexp-replace* #px"</?b>" 
        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                         (regexp-match rx str)))) ""))
    (make-object button% "Open" zp (λ (btn evt)
             (send-url link)))
    (make-object message% lbl zp)))

(define (postparse-duck strs)
  (for ([ch (send group-box-panel get-children)])
    (send group-box-panel delete-child ch))
  (for ([str strs]
        [i (in-naturals 1)]
        #:when (< i 11))
    (define zp (new horizontal-panel%
               [parent group-box-panel]
               [alignment '(left center)]))
    (define link
      (bytes->string/utf-8 (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                         (regexp-match rx str)))))
    (define lbl
      (regexp-replace* #px"</?b>" 
        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                         (regexp-match rx str)))) ""))
    (make-object button% "Open" zp (λ (btn evt)
             (send-url link) #|(message-box "link" link)|# )) #| DEBUG |#
    (make-object message% lbl zp)))

(define p (new horizontal-panel%
               [parent f]
               [alignment '(right top)]))
(define google (new button%
                    [parent p]
                    [label "Google"]
                    [callback (λ (btn evt)
     (postparse (let-me-google-that-for-you (send lmgfy get-value))))]))
(define duck (new button%
                  [parent p]
                  [label "DuckDuckGo"]
                  [callback (λ (btn evt)
     (postparse-duck (let-me-duck-that-for-you (send lmgfy get-value))))]))
(define about (new button%
                    [parent p]
                    [label "About"]
                    [callback (λ (btn evt)
     (message-box "Search Serene" "  Search Serene 1.1 by Heather  "))]))

(send f show #t)

