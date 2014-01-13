#lang racket
(require net/url net/uri-codec net/sendurl)

(let* ([duck-search (λ (target)
          (for ([str (let* ([g "https://duckduckgo.com/html/?q="]
                            [u (string-append g (uri-encode target))]
                            [rx #rx"(?<=<a rel=\"nofollow\" class=\"large\").*?(?=</a>)"])
                       (regexp-match* rx (get-pure-port (string->url u))))]
                [i (in-naturals 1)]
                #:when (< i 14)) ; Just to show as much as Google
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

  (google-search (string-join (vector->list (current-command-line-arguments)))))