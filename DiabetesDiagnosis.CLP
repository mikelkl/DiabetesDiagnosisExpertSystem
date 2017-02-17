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
  (slot more-consideration))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; load current diagnosis fact ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffacts load_facts
  (current_fact (diagnosis healthy) (cf 0))
  (current_fact (diagnosis at-risk) (cf 0))
  (current_fact (diagnosis diabetes-type-I) (cf 0))
  (current_fact (diagnosis diabetes-type-II) (cf 0))
  (current_fact (diagnosis gestational-diabetes) (cf 0))
  (current_fact (diagnosis more-consideration) (cf 0))

  (current_goal (diagnosis healthy) (cf 0))
  (current_goal (diagnosis at-risk) (cf 0))
  (current_goal (diagnosis diabetes-type-I) (cf 0))
  (current_goal (diagnosis diabetes-type-II) (cf 0))
  (current_goal (diagnosis gestational-diabetes) (cf 0))
  (current_goal (diagnosis more-consideration) (cf 0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;Symptoms question ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Symptoms: Excessive Urination
(defrule ex_urinate                                      
  =>      
  (printout t "Do you have Excessive Urination?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-ex-urinate ?answer))
)

;;; Symptoms: Polydipsia
(defrule polydipsia                                      
  =>      
  (printout t "Do you have Polydipsia (mean increased thirst)?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-polydipsia ?answer))
)

;;; Symptoms: Polyphagia
(defrule polyphagia                                      
  =>     
  (printout t "Do you have Polyphagia (Feeling Hungry)?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-polyphagia ?answer))
)

;;; Symptoms: Tiredness
(defrule tiredness                                      
  =>      
  (printout t "Do you have Tiredness?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-tiredness ?answer))
)

;;; Symptoms: Losing Weight without Reason
(defrule lose_weight                                      
  =>      
  (printout t "Do you have losing weight without reason?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-lose-weight ?answer))
)


;;; Symptoms: Frequent Infections
(defrule infection                                      
  =>      
  (printout t "Do you have Frequent Infections?(yes/no)" crlf)      
  (bind ?answer (read))
  (assert (symp-infection ?answer))
)

(defrule assert_symptoms_diabetes
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

(defrule assert_symptoms_healthy
  (declare (salience -10))
  (symp-ex-urinate no)
  (symp-polydipsia no)
  (symp-polyphagia no)
  (symp-tiredness no)
  (symp-lose-weight no)
  (symp-infection no)
  =>
  (assert (symp healthy))
)


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
      (assert (rf-gestational no)))
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

(defrule assert_risk_factors_at_risk
  (declare (salience -10))
  (or (user-age yes)
      (rf-obesity yes)
      (rf-gestational yes)
      (rf-triglyceridges yes)
  )
  =>
  (assert (risk-factors at-risk))
)

(defrule assert_risk_factors_healthy
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
      (assert (Test unhealthy-gestational))
      else
      (assert (Test healthy)))
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
  (printout t "What's your Casual Plasma Glucose (mmol/l)?" crlf)      
  (bind ?answer2 (read))
  (if (and (>= ?answer1 7.0) (>= ?answer2 11.1))
      then
      (assert (Test unhealthy)))
  (if (and (< ?answer1 7.0) (< ?answer2 11.1))
      then
      (assert (Test healthy)))
  (if (and (>= ?answer1 7.0) (< ?answer2 11.1))
      then
      (assert (Test more-consideration)))
  (if (and (< ?answer1 7.0) (>= ?answer2 11.1))
      then
      (assert (Test more-consideration)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;; Desicion Result ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(deffunction family (?cf-h ?cf-r ?cf-I ?cf-II ?cf-g ?cf-m)
  (printout t crlf "Our diagnosis is as follows :")
  (printout t crlf "Healthy: " (integer (* ?cf-h 100)) "%")
  (printout t crlf "At Risk: " (integer (* ?cf-r 100)) "%")
  (printout t crlf "Diabetes Type I: " (integer (* ?cf-I 100)) "%")
  (printout t crlf "Diabetes Type II: " (integer (* ?cf-II 100)) "%")
  (printout t crlf "Gestational Diabetes: " (integer (* ?cf-g 100)) "%" crlf)
  (printout t crlf "More Consideration: " (integer (* ?cf-m 100)) "%" crlf)
  (assert (result (healthy ?cf-h) (at-risk ?cf-r) (diabetes-type-I ?cf-I) (diabetes-type-II ?cf-II) (gestational-diabetes ?cf-g)
    (more-consideration ?cf-m)))
)

;;; create diagnosis result
(defrule diagnosis_healthy
  (Test healthy)
  (symp healthy)
  (risk-factors healthy)
  =>
  (family 1 0 0 0 0 0)
)

(defrule diagnosis_at_risk
  (Test healthy)
  (symp healthy)
  (risk-factors at-risk)
  =>
  (family 0 1 0 0 0 0)
)

(defrule diagnosis_diabetes_type_I
  (Test unhealthy)
  (or (user-gender M)
    (user-pregnant no))
  (user-age no)
  (symp diabetes)
  =>
  (family 0 0 1 0 0 0)
)

(defrule diagnosis_diabetes_type_II
  (Test unhealthy)
  (user-age yes)
  (symp diabetes)
  =>
  (family 0 0 0 1 0 0)
)

(defrule diagnosis_gestational_diabetes
  (Test unhealthy-gestational)
  (user-pregnant no)
  (symp diabetes)
  =>
  (family 0 0 0 0 1 0)
)

(defrule diagnosis_more_consideration
  (or (and (Test healthy)
          (symp diabetes)
          (risk-factors at-risk))
      (and (Test unhealthy)
          (user-pregnant yes)
          (user-age no))
      (and (Test unhealthy-gestational)
          (user-pregnant yes)
          (symp healthy))
      (and (Test unhealthy)
          (symp healthy))
      (Test more-consideration)
  )
  =>
  (family 0 0 0 0 0 1)
)