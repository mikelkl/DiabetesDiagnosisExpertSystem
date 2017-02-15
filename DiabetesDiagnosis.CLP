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
;;;;;;;;;;;;;;;;;;;;;;;;Symptoms question ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Symptoms: Excessive Urination
; (defrule ex-urinate                                      
;   =>      
;   (printout t "Do you have Excessive Urination?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-ex-urinate ?answer))
; )

; ;;; Symptoms: Polydipsia
; (defrule polydipsia                                      
;   =>      
;   (printout t "Do you have Polydipsia (mean increased thirst)?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-polydipsia ?answer))
; )

; ;;; Symptoms: Polyphagia
; (defrule polyphagia                                      
;   =>     
;   (printout t "Do you have Polyphagia (Feeling Hungry)?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-polyphagia ?answer))
; )

; ;;; Symptoms: Tiredness
; (defrule tiredness                                      
;   =>      
;   (printout t "Do you have Tiredness?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-tiredness ?answer))
; )

; ;;; Symptoms: Losing Weight without Reason
; (defrule lose-weight                                      
;   =>      
;   (printout t "Do you have losing weight without reason?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-lose-weight ?answer))
; )


; ;;; Symptoms: Frequent Infections
; (defrule infection                                      
;   =>      
;   (printout t "Do you have Frequent Infections?(yes/no)" crlf)      
;   (bind ?answer (read))
;   (assert (symp-infection ?answer))
; )

; (defrule assert-symptoms-diabetes
;   (declare (salience -10))
;   (or (symp-ex-urinate yes)
;       (symp-polydipsia yes)
;       (symp-polyphagia yes)
;       (symp-tiredness yes)
;       (symp-lose-weight yes)
;       (symp-infection yes)
;   )
;   =>
;   (assert (symp diabetes))
; )

; (defrule assert-symptoms-healthy
;   (declare (salience -10))
;   (and (symp-ex-urinate no)
;       (symp-polydipsia no)
;       (symp-polyphagia no)
;       (symp-tiredness no)
;       (symp-lose-weight no)
;       (symp-infection no)
;   )
;   =>
;   (assert (symp healthy))
; )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;Risk Factors question ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; User: Age
(defrule age                                      
  =>      
  (printout t "What's your age?" crlf)      
  (bind ?answer (read))
  (if (>= ?answer 20)
      then
      (assert (user-age yes))
      else
      (assert (user-age no)))
)

;;; User: Gender
(defrule gender                                      
  =>      
  (printout t "What's your gender?(M/F)" crlf)      
  (bind ?answer (read))
  (assert (user-gender ?answer))
  (if (eq ?answer M)
      then
      (assert (rf-gestational no))
)

;;; Risk Factors: Obesity
(defrule obesity                                      
  =>      
  (printout t "Do you have Obesity?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (rf-obesity ?answer))
)

;;; Risk Factors: History of gestational diabetes or Having Baby with over 4 Kg weight (female only)
(defrule gestational
  (user-gender F)
  =>      
  (printout t "Do you have History of gestational diabetes or Having Baby with over 4 Kg weight?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (rf-gestational ?answer))
)

;;; Risk Factors: Rate of Triglyceridges (TG - one of the cholesterol)
(defrule triglyceridges                                      
  =>    
  (printout t "Do you have Rate of Triglyceridges?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (rf-triglyceridges ?answer))
)

(defrule assert-risk-factors-at-risk
  (declare (salience -10))
  (or (user-age yes)
      (rf-obesity yes)
      (rf-gestational yes)
      (rf-triglyceridges yes)
  )
  =>
  (assert (risk-factors at_risk))
)

(defrule assert-risk-factors-healthy
  (declare (salience -10))
  (user-age no)
  (rf-obesity no)
  (rf-gestational no)
  (rf-triglyceridges no)
  =>
  (assert (risk-factors healthy))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;Test question ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; User: Pregnant
(defrule pregnant
  (declare (salience -5))   
  (user-gender F)
  =>      
  (printout t "Are you Pregnant?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (user-pregnant ?answer))
)

;;; Test: 2-hour post Oral Glucose Tolerance Test (OGTT)
(defrule ogtt
  (declare (salience -6))
  (user-gender F)
  (user-pregnant yes)
  =>      
  (printout t "What's your 2-hour post Oral Glucose Tolerance Test (mmol/l)?" crlf)      
  (bind ?answer (read))
  (if (>= ?answer 7.8)
      then
      (assert (test unhealthy-gestational))
      else
      (assert (test healthy)))
)

;;; Test: Casual Plasma Glucose (CPG) & Casual Plasma Glucose (CPG)
(defrule cpf_cpg
  (declare (salience -7))
  (or (user-gender M)
    (user-pregnant no)
  )
  =>      
  (printout t "What's your Fasting Plasma Glucose (mmol/l)?" crlf)      
  (bind ?answer1 (read))
  (if (>= ?answer 7.0)
      then
      (assert (test-fpg yes))
      else
      (assert (test-fpg no)))

  (printout t "What's your Casual Plasma Glucose (mmol/l)?" crlf)      
  (bind ?answer2 (read))
  (if (and (>= ?answer 7.0) (>= ?answer2 11.1))
      then
      (assert (test unhealthy)))
  (if (and (< ?answer 7.0) (< ?answer2 11.1))
      then
      (assert (test healthy)))
  (if (and (>= ?answer 7.0) (< ?answer2 11.1))
      then
      (assert (test more-consideration)))
  (if (and (< ?answer 7.0) (>= ?answer2 11.1))
      then
      (assert (test more-consideration)))
)
