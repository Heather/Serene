#lang racket
(require net/url net/uri-codec net/sendurl racket/cmdline)

(define (wipe)
  (display-to-file "" ".ss"
                   #:mode 'text
                   #:exists 'truncate/replace))
(define (save v p)
  (if (= p 0)
      (display-to-file (string-append v "\n") ".ss"
                       #:mode 'text
                       #:exists 'append)
      (display-to-file (string-append v "\n") ".ss"
                       #:mode 'text
                       #:exists 'append)))
(define (open v)
  (send-url
   (list-ref (file->lines ".ss" #:mode 'text)
             (- v 1))))

(define (serene base baserx i0 getHttp getDescription)
  (λ (target)
    (let ([u (string-append base (uri-encode target))])
    (for ([str (regexp-match* baserx (get-pure-port (string->url u)))]
          [i (in-naturals 1)]
          #:when (> i i0))
      (let* ([http (getHttp str)]
             [desc (getDescription str)])
              (display (- i i0))
              (display " : ")
              (display http)
              (save http 0)
              (display " > ")
              (displayln desc)
        )))))

(let* ([duck-search (serene "https://duckduckgo.com/html/?q="
                            #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)" 1
                            (λ (str) (bytes->string/utf-8 
                                      (car (let ([rx #rx"(?<=href=\").*?(?=\">)"])
                                             (regexp-match rx str)))))
                            (λ (str) (regexp-replace* #px"</?b>" 
                                                      (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*"])
                                                                                  (regexp-match rx str))))"")))]
       
       [google-search (serene "https://www.google.com/search?q="
                              #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)" 0
                              (λ (str) (regexp-replace* #px"url[?]q=" 
                                                        (bytes->string/utf-8 (car (let ([rx #rx"(?<= href=\"/).*?(?=&amp)"])
                                                                                    (regexp-match rx str)))) ""))
                              (λ (str) (regexp-replace* #px"</?b>" 
                                                        (bytes->string/utf-8 (car (let ([rx #rx"(?<=\">).*?(?=</a>)"])
                                                                                    (regexp-match rx str)))) "")))])
  
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
                      (let ([A (string-join all)]) (wipe)
                        (if google-mode?
                            (google-search A)
                            (duck-search A)))
                      (if (regexp-match? #rx"[0-9]*" openlink)
                          (open (string->number openlink))
                          (send-url openlink)
                          ))
                  (displayln "Search Servene v.1.7"))))
