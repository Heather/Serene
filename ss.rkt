#lang racket
(require net/url net/uri-codec net/sendurl racket/cmdline)

(define (wipe)
  (display-to-file "" ".ss"
                 #:mode 'text
                 #:exists 'truncate/replace))
(define (save v)
  (display-to-file (string-append v "\n") ".ss"
                 #:mode 'text
                 #:exists 'append))
(define (open v)
  (send-url
   (list-ref (file->lines ".ss" #:mode 'text)
             (- v 1))))

(let* ([duck-search (λ (target) (wipe)
          (for ([str (let* ([g "https://duckduckgo.com/html/?q="]
                            [u (string-append g (uri-encode target))]
                            [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"])
                       (regexp-match* rx (get-pure-port (string->url u))))]
            [i (in-naturals 1)]
            #:when (and (< i 15) (> i 1)))
            (display (- i 1))
            (display " : ")
            (let ([http (bytes->string/utf-8 
                   (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                   (regexp-match rx str))))])
               (display http)
               (save http))
               (display " > ")
               (displayln (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                   (regexp-match rx str))))""))))]
       
       [google-search (λ (target) (wipe)
            (for ([str (let* ([g "https://www.google.com/search?q="]
                              [u (string-append g (uri-encode target))]
                              [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
                         (regexp-match* rx (get-pure-port (string->url u))))]
              [i (in-naturals 1)])
              (display i)
              (display " : ")
              (let ([http (regexp-replace* #px"url[?]q=" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=&amp)"])
                   (regexp-match rx str)))) "")])
                (display http)
                (save http))
                (display " > ")
                (displayln (regexp-replace* #px"</?b>" 
                   (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                   (regexp-match rx str)))) ""))))])
  
  (define no-v? (make-parameter #true))
  (define google-mode? (make-parameter #true))
  (define openlink "")
  
  (command-line
   #:once-each
   [("-v" "--version") "Display search serene version"
                    (set! no-v? #false)]
   [("-o" "--open") string "Open an link"
                    (set! openlink string)]
   #:once-any
   [("-d" "--duck") "Duck Duck Go"
                    (set! google-mode? #false)]
   [("-g" "--google") "Google"
                    (set! google-mode? #true)]
   #:args all (if no-v?
                  (if (string=? openlink "")
                      (let ([A (string-join all)])
                        (if google-mode?
                            (google-search A)
                            (duck-search A)))
                      (if (regexp-match? #rx"[0-9]*" openlink)
                          (open (string->number openlink))
                          (send-url openlink)
                          ))
                  (displayln "Search Servene v.1.6"))))
