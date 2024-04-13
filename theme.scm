(define-module (theme)
  #:use-module (haunt artifact)
  #:use-module (haunt builder blog)
  #:use-module (haunt html)
  #:use-module (haunt post)
  #:use-module (haunt site)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-19)
  #:use-module (utils)
  #:export (p-snow-theme))

(define (first-paragraph post)
  (let loop ((sxml (post-sxml post))
             (result '()))
    (match sxml
      (() (reverse result))
      ((or (('p ...) _ ...) (paragraph _ ...))
       (reverse (cons paragraph result)))
      ((head . tail)
       (loop tail (cons head result))))))

(define p-snow-theme
  (theme #:name "p-snow"
         #:layout
         (lambda (site title body)
           `((doctype "html")
             (head
              (meta (@ (charset "utf-8")))
              (title ,(string-append title " — " (site-title site)))
              (link (@ (rel "alternate")
                       (type "application/atom+xml")
                       (title "Atom feed")
                       (href "/feed.xml")))
              ,(stylesheet "style"))
             (body
              (div (@ (class "container"))
                   (div (@ (class "nav"))
                        (ul (li ,(link (site-title site) "/"))
                            (li (@ (class "fade-text")) " ")
                            (li ,(link "Blog" "/index.html"))
                            (li ,(link "日本語記事" "/index-ja.html"))
                            (li ,(link "My Config" "https://github.com/p-snow/config"))
                            (li ,(link "RSS" "/feed.xml"))))
                   ,body))))
         #:post-template
         (lambda (post)
           `((h1 (@ (class "title")),(post-ref post 'title))
             (div (@ (class "date"))
                  ,(date->string (post-date post)
                                 "~B ~d, ~Y"))
             (div (@ (class "tags"))
                  "Tags:"
                  (ul ,@(map (lambda (tag)
                               `(li (a (@ (href ,(string-append "/feeds/tags/"
                                                                tag ".xml")))
                                       ,tag)))
                             (assq-ref (post-metadata post) 'tags))))
             (div (@ (class "post"))
                  ,(post-sxml post))))
         #:collection-template
         (lambda (site title posts prefix)
           (define (post-uri post)
             (string-append prefix "/" (site-post-slug site post) ".html"))
           `((h1 ,title)
             ,(map (lambda (post)
                     (let ((uri (post-uri post)))
                       `(div (@ (class "summary"))
                             (h2 (a (@ (href ,uri))
                                    ,(post-ref post 'title)))
                             (div (@ (class "date"))
                                  ,(date->string (post-date post)
                                                 "~B ~d, ~Y"))
                             (div (@ (class "post"))
                                  ,(first-paragraph post))
                             (a (@ (href ,uri)) "read more ➔"))))
                   posts)))
         #:pagination-template
         (lambda (site body previous-page next-page)
           `(,@body
             (div (@ (class "paginator"))
                  ,(if previous-page
                       `(a (@ (class "paginator-prev") (href ,previous-page))
                           "🡐 Newer")
                       '())
                  ,(if next-page
                       `(a (@ (class "paginator-next") (href ,next-page))
                           "Older 🡒")
                       '()))))))