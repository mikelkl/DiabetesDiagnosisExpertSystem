;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This program is written by Liu Kanglong, Tan Xinli Steven, Meng Yang, Lwi Tiong Chai, Dipti Bijpuria, Tan Xinli Steven, 2016, NUS (Copyright).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; define diagnosis template
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deftemplate current_fact (slot diagnosis) (slot cf))

;; the top-level
(deftemplate current_goal (slot diagnosis) (slot cf)) 

;; Temporary variable
(deftemplate working_goal (slot diagnosis) (slot cf)) ;; 

;; store the final result
(deftemplate result 
        (slot healthy) 
        (slot at-risk) 
        (slot diabetes-type-I) 
        (slot diabetes-type-II) 
        (slot gestational-diabetes)
        (slot more_consideration))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; load current diagnosis fact ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffacts load-facts
        (current_fact (diagnosis healthy) (cf 0))
        (current_fact (diagnosis at-risk) (cf 0))
        (current_fact (diagnosis diabetes-type-I) (cf 0))
        (current_fact (diagnosis diabetes-type-II) (cf 0))
        (current_fact (diagnosis gestational-diabetes) (cf 0))
        (current_fact (diagnosis more_consideration) (cf 0))

        (current_goal (diagnosis healthy) (cf 0))
        (current_goal (diagnosis at-risk) (cf 0))
        (current_goal (diagnosis diabetes-type-I) (cf 0))
        (current_goal (diagnosis diabetes-type-II) (cf 0))
        (current_goal (diagnosis gestational-diabetes) (cf 0))
        (current_goal (diagnosis more_consideration) (cf 0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; question ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Symptoms: Excessive Urination
(defrule ex-urinate                                      
=>      (printout t "Do you have Excessive Urination?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-ex-urinate ?answer))
        ; (assert (ask_veg Yes))
)

;;; Symptoms: Polydipsia
(defrule polydipsia                                      
=>      (printout t "Do you have Polydipsia (mean increased thirst)?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-polydipsia ?answer))
        ; (assert (ask_veg Yes))
)

;;; Symptoms: Polyphagia
(defrule polyphagia                                      
=>      (printout t "Do you have Polyphagia (Feeling Hungry)?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-polyphagia ?answer))
        ; (assert (ask_veg Yes))
)

;;; Symptoms: Tiredness
(defrule tiredness                                      
=>      (printout t "Do you have Tiredness?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-tiredness ?answer))
        ; (assert (ask_veg Yes))
)

;;; Symptoms: Losing Weight without Reason
(defrule lose-weight                                      
=>      (printout t "Do you have losing weight without reason?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-lose-weight ?answer))
        ; (assert (ask_veg Yes))
)


;;; Symptoms: Frequent Infections
(defrule infection                                      
=>      (printout t "Do you have Frequent Infections?(yes/no)" crlf)      
        (bind ?answer (read))
        (assert (symp-infection ?answer))
        ; (assert (ask_veg Yes))
)

(defrule assert-symptoms-diabetes
        (declare (salience -10))
        (or (symp-ex-urinate yes)
            (symp-polydipsia yes)
            (symp-polyphagia yes)
            (symp-tiredness yes)
            (symp-lose-weight yes)
            (symp-infection yes)
        )
  =>
  (assert (symp diabetes))
)

(defrule assert-symptoms-healthy
  (declare (salience -10))
  (and (symp-ex-urinate no)
      (symp-polydipsia no)
      (symp-polyphagia no)
      (symp-tiredness no)
      (symp-lose-weight no)
      (symp-infection no)
  )
  =>
  (assert (symp healthy))
)