#lang racket
(require net/url net/uri-codec net/sendurl racket/cmdline)

(let* ([duck-search (λ (target)
          (for ([str (let* ([g "https://duckduckgo.com/html/?q="]
                            [u (string-append g (uri-encode target))]
                            [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"])
                       (regexp-match* rx (get-pure-port (string->url u))))]
                [i (in-naturals 1)]
                #:when (and (< i 15) (> i 1)))
               (display (bytes->string/utf-8 
                   (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                   (regexp-match rx str)))))
               (display " > ")
               (displayln (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                   (regexp-match rx str))))""))))]
       
       [google-search (λ (target)
            (for ([str (let* ([g "https://www.google.com/search?q="]
                              [u (string-append g (uri-encode target))]
                              [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
                         (regexp-match* rx (get-pure-port (string->url u))))])
                (display (regexp-replace* #px"url[?]q=" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=&amp)"])
                   (regexp-match rx str)))) ""))
                (display " > ")
                (displayln (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                   (regexp-match rx str)))) ""))))])
  
  (define no-v? (make-parameter #true))
  (define google-mode? (make-parameter #true))
  
  (command-line
   #:once-each
   [("-v" "--version") "Display search serene version"
                    (set! no-v? #false)]
   #:once-any
   [("-d" "--duck") "Duck Duck Go"
                    (set! google-mode? #false)]
   [("-g" "--google") "Google"
                    (set! google-mode? #true)]
   #:args all (if no-v?
               (let ([A (string-join all)])
                (if google-mode?
                    (google-search A)
                    (duck-search A)))
                (displayln "Search Servene v.1.5"))))
