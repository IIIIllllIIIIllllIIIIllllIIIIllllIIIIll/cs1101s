(require racket/mpair)

(define (make-component name owner)
  (let ((base (make-named-object name)))
    (lambda (message)
      (case message        
        ((initialize)
         (lambda (self data)
           (void)))
        
        ((post-initialize)
         (lambda (self)
           (void)))
        
        ((destroy)
         (lambda (self)
           (void)))
        
        ((owner) (lambda (self) owner))
        
        ((dump) (lambda (self) (void)))
        
        (else (get-method base message))))))

(define (make-entity template)
  (let* ((base (make-named-object (ask template 'name)))
         (properties '())
         (components '())
         (self
          (lambda (message)
            (case message
              ((attach-component)
               (lambda (self component)
                 ;(display-multi "Attached " (ask component 'name) " to " (ask self 'name))
                 (set! components (cons component components))
                 (ask component 'post-initialize)))
              
              ((find-component)
               (lambda (self pred)
                 (findf pred components)))
              
              ((find-component-by-name)
               (lambda (self name)
                 (ask self 'find-component (lambda (comp)
                                             (equal? name (ask comp 'name))))))
              
              ((dump)               
               (lambda (self)
                 (display "Dumpping ")(newline)
                 (display (ask self 'name))
                 (for-each (lambda (component)
                             (display '------)(newline)                             
                             (display (ask component 'name))(newline)
                             (ask component 'dump)
                             (newline))
                           components)))
              
              ((get-property)
               (lambda (self name)
                 (let ((pair (massoc name properties)))
                   (if pair
                       (cdr pair)
                       #f))))
              
              ((set-property)
               (lambda (self name value)
                 (let ((pair (massoc name properties)))
                   (if pair
                       (set-mcdr! pair value)
                       (set! properties (mcons (mcons name value)
                                               properties))))))
              
              (else
               (let ((base-method (get-method base message)))
                 (if (not (no-method? base-method))
                     base-method
                     (lambda params
                       (let ((dispatched #f)
                             (result (void)))
                         (for-each
                          (lambda (comp)
                            (let ((method (get-method comp message)))
                              (if (not (no-method? method))
                                  (begin
                                    (set! dispatched #t)
                                    (set! result (apply method (cons comp (cdr params))))))));replace self with comp
                          components)
                         (if dispatched
                             result))))))))))
    
    ;create all components
    (for-each
     (lambda (template-entry)
       (let* ((component-constructor                
               (if (pair? template-entry)
                   (car template-entry)
                   template-entry))
              
              (component (component-constructor self)))
         
         (if (pair? template-entry)
             (ask component 'initialize (cdr template-entry)))
         (set! components (cons component components))))
     (ask template 'components))
    ;post-initialize
    (for-each
     (lambda (component)
       (ask component 'post-initialize))
     components)
    self))

(define (make-template name . components)
  (let ((base (make-named-object name)))
    (lambda (message)
      (case message
        ((components)
         (lambda (self) components))
        (else (get-method base message))))))

(define (extend-template template new-name . extensions)
  (define (helper extensions acc)
    (if (null? extensions)
        acc
        (let* ((entry (car extensions))
               (key (if (pair? entry) (car entry) entry)))          
          (helper (cdr extensions)
                  (append (filter (lambda (entry)
                                    (not (eq? (if (pair? entry) (car entry) entry)
                                              key)))
                                  acc)
                          (list entry))))))
  (apply make-template (cons new-name (helper extensions (ask template 'components)))))

(define (has-a? ent name)
  (ask ent 'find-component-by-name name))

(define (make-desc constructor)
  (lambda (data)
    (if (list? data)
        (cons constructor data)
        (error "This is a descriptor for " constructor))))