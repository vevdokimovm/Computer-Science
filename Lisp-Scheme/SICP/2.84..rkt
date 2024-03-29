#lang racket

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args))
                    (subtype (subtype type1 type2)))
                (if (and (eq? type1 type2) (eq? type1 'complex))
                    (error "Нет метода для этих типов -- APPLY-GENERIC" (list op type-tags))
                    (cond ((eq? type1 type2) (apply-generic op (raise a1) (raise a2)))
                          ((eq? subtype type1)(apply-generic op (raise a1) a2))
                          ((eq? subtype type2) (apply-generic op a1 (raise a2))))))
              (error "Нет метода для этих типов"
                     (list op type-tags)))))))

(define type-tower '(scheme-number rational real complex))

(define (subtype type1 type2)
  (let ((place1 (find-in-tower type1 type-tower))
        (place2 (find-in-tower type2 type-tower)))
    (if (> place1 place2)
        type2
        type1)))

(define (find-in-tower type tower)
  (if (eq? type (car tower))
      0
      (+ 1 (find-in-tower type (cdr tower)))))