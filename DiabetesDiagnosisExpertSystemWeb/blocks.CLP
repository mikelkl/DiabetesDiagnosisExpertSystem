
;;;======================================================
;;;   Blocks World Program
;;;
;;;     This program was introduced in Chapter 8.
;;;
;;;     CLIPS Version 6.0 Example
;;;
;;;     For use with the Clipsjni
;;;======================================================

(deftemplate goal (slot move) (slot on-top-of))
(deftemplate action (slot move) (slot on-top-of))

(deffacts initial-state
   (stack A B C)
   (stack D E F)
;   (goal (move C) (on-top-of E))
   (stack))

(defrule move-directly
   ?goal <- (goal (move ?block1) (on-top-of ?block2))
   ?stack-1 <- (stack ?block1 $?rest1)
   ?stack-2 <- (stack ?block2 $?rest2)
   =>
   (retract ?goal ?stack-1 ?stack-2)
   (assert (stack $?rest1))
   (assert (stack ?block1 ?block2 $?rest2))
   (assert (action (move ?block1) (on-top-of ?block2))))

(defrule move-to-floor
   ?goal <- (goal (move ?block1) (on-top-of floor))
   ?stack-1 <- (stack ?block1 $?rest)
   =>
   (retract ?goal ?stack-1)
   (assert (stack ?block1))
   (assert (stack $?rest))
   (assert (action (move ?block1) (on-top-of floor))))

(defrule clear-upper-block 
   (goal (move ?block1))
   (stack ?top $? ?block1 $?)
   =>
   (assert (goal (move ?top) (on-top-of floor)))) 

(defrule clear-lower-block
   (goal (on-top-of ?block1))
   (stack ?top $? ?block1 $?)
   =>
   (assert (goal (move ?top) (on-top-of floor))))
