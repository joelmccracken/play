#lang racket

(require rackunit
         rackunit/text-ui)

(define (check-does-not-finish-speedily thunk secs)
  (let ([checker-thread (thread thunk)])
    (for ([i (in-range secs)])
         (if (not (thread-running? checker-thread))
             (raise "executed speedily")
             '())
         (sleep 1))
    (kill-thread checker-thread)))


(define ex-1.1-tests
  (test-suite
   "tests for equality"
   (check-equal? 10 10)
   (check-equal? (+ 5 4 9) 18)
   (check-equal? (- 9 1) 8)
   (check-equal? (/ 6 2) 3)
   (check-equal? (+ (* 2 4) (- 4 6)) 6)
   ;; (define ...) does not return anything on the repl
   (let* ((a 3)
          (b (+ a 1)))
     (check-equal? (+ a b (* a b)) 19)
     (check-equal? (= a b) #f)

     (check-equal?
      (if (and (> b a) (< b (* a b)))
          b
          a)
      4)
     (check-equal?
      (cond ((= a 4) 6)
            ((= b 4) (+ 6 7 a))
            (else 25))
      16)
     (check-equal?
      (+ 2 (if (> b a) b a))
      6)
     (check-equal?
      (* (cond ((> a b) a)
               ((< a b) b)
               (else -1))
         (+ a 1))
      16))))


(define ex-1.2-tests
  (test-suite
   "translate expression into prefix-notation"
   (check-equal?
    (/ (+ 5 4 (- 2 (- 3 (+ 6 4/5))))
       (* 3 (- 6 2) (- 2 7)))
    -37/150)))



(define (square x)
  (* x x))

(define (sum-of-squares-of-larger-two a b c)
  (let ((a2 (square a))
        (b2 (square b))
        (c2 (square c)))
    (+ a2 b2 c2 (- (min a2 b2 c2)))))


(define ex-1.3-tests
  (test-suite
   "Define a procedure that takes three numbers as arguments and returns the sum of the squares of the two larger numbers."

   (check-equal? (sum-of-squares-of-larger-two 1 2 3)
                 13)

   (check-equal? (sum-of-squares-of-larger-two 4 2 3)
                 25)

   (check-equal? (sum-of-squares-of-larger-two 5 6 3)
                 61)

   )
  )

#|
Exercise 1.4. Answer:

Since the operator (if...) either returns a + or a -,
if b < 0, the expression becomes (- a b)
if b > 0, the expression becomes (+ a b)

Either case is equivalent to "a plus the abs value of b"
|#


#|
Exercise 1.5. Answer:

In the applicative case, `test` will evaluate both 0 and (p). However, (p) will loop infinitely.
In the normal order case, the evaluation will follow:

(test 0 (p)) ; 0 -> 0, (p) -> (p), test -> (if...)
(if (= 0 0)
    0
    (p)) ; 0 -> 0
0

I *think* this is the case. I might actually be a little wrong, because it seems as though there should be a discussion
of environments here that I am missing. There is no discussion on environments in this section, so I assume it is
over-thinking, but it *seems* that in a normal-order situation the evaluation of (p) would be infinite,
because the p inside would need to be expanded. I guess this is why y combinator.
|#


#|
Exercise 1.6 Answer:

new-if will evaluate both the `then` and `else` clauses. Thus, sqrt-iter is called
infinitely, because calling it once forces it to be called again, and again, etc.
|#

(define ex-1.7-tests
  (test-suite
   "`good-enough?` precision tests"
   (let ()
     ;; define methods from the text
     (define (sqrt-iter guess x)
       (if (good-enough? guess x)
           guess
           (sqrt-iter (improve guess x)
                      x)))

     (define (improve guess x)
       (average guess (/ x guess)))

     (define (average x y)
       (/ (+ x y) 2))

     (define (sqrt x)
       (sqrt-iter 1.0 x))

     ;; throughout this test good-enough? will be
     ;; redefined many times. here is the initial version
     (define (good-enough? guess x)
       (< (abs (- (square guess) x)) 0.001))

     ;; there are two cases under discussion here
     ;; the first is finding the square root of a very small number.
     ;; the problem lies in the tolerance setting TS, above set to
     ;; 0.001. When the X we are looking for in (sqrt X) is little,
     ;; the X - (square guess) has a wide range of possible solutions,
     ;; all less than TS.
     ;; here is an example that illustrates the problem

     ;; note: this might fail on a different platform, because the
     ;; exact answer would be different
     (let ((incorrect-root-answer 0.03230844833048122))
       ;; the answer listen in the let above is incorrect. Here we see
       ;; that it is what the sqrt method returns
       (check-equal? (sqrt 0.0001) incorrect-root-answer)

       ;; and here we see that the square of this provided root is
       ;;                         very different from 0.0001
       (check-equal? (square incorrect-root-answer)   0.0010438358335233748))

     ;; The second case under discussion is when limited precision
     ;; numbers are used for very large integers. This is made
     ;; complicated by using Racket to work through these
     ;; examples, as Racket has its own interesting number system.
     ;; In Racket, when large, inexact numbers are in play, these are
     ;; stored as exponents and addition operations do not store
     ;; precise detail -- thus the guess will never be within the TS,
     ;; as no guess will store enough detail. So, we should expect the
     ;; algorithm to infinitely recurse. The exception to this is
     ;; that if the square root of X we are solving for happens to be
     ;; guessed, and that X is also precisely one of these numbers
     ;; that a large number is stored as, this algorithm should still
     ;; work.
     (check-exn exn:fail?
                (check-does-not-finish-speedily
                 (thunk
                  (let ([really-large-number 110798789796967820678678678729834.0])
                    (check-equal? (sqrt really-large-number) 10)))
                 0.1))

     ;; the next piece of this -- writing a better `good-enough?` --
     ;; still needs to be done. The general idea is to check to see if
     ;; forward progress is being made, and otherwise return the results.


     )))

;; (require rackunit/gui)



(run-tests ex-1.1-tests)
(run-tests ex-1.2-tests)
(run-tests ex-1.3-tests)
(run-tests ex-1.7-tests)