(deftemplate current_fact (slot fact) (slot cf))
(deftemplate current_goal (slot goal) (slot cf)) ;; the top-level
(deftemplate working_goal (slot goal) (slot cf)) ;;
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
  (current_fact (fact healthy) (cf 0.0))
  (current_fact (fact at-risk) (cf 0.0))
  (current_fact (fact diabetes-type-I) (cf 0.0))
  (current_fact (fact diabetes-type-II) (cf 0.0))
  (current_fact (fact gestational-diabetes) (cf 0.0))
  (current_fact (fact more-consideration) (cf 0.0))

  (current_goal (goal healthy) (cf 0.0))
  (current_goal (goal at-risk) (cf 0.0))
  (current_goal (goal diabetes-type-I) (cf 0.0))
  (current_goal (goal diabetes-type-II) (cf 0.0))
  (current_goal (goal gestational-diabetes) (cf 0.0))
  (current_goal (goal more-consideration) (cf 0.0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; initialise current goal when a new_goal is asserted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (defrule initialise-current-goal
;	(working_goal (goal ?ng) (cf ?cfng))
;	(not (current_goal (goal ?cg) (cf ?cfg)))
;	?newg <- (working_goal (goal ?ng) (cf ?cfng))
;=> 	(assert (current_goal (goal ?ng) (cf ?cfng)))
;	(retract ?newg)
;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CF combination for multiple conclusions RULES
;;; treat this as a black-box
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;combine POSITIVE certainty factors for multiple conclusions
;cf(cf1,cf2) = cf1 + cf2 * (1- cf1)

(defrule combine-positive-cf
  ?f1 <- (current_goal (goal ?g)(cf ?cf1&:(>= ?cf1 0)))
  ?f2 <- (working_goal (goal ?g)(cf ?cf2&:(>= ?cf2 0)))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(+ ?cf1 (* ?cf2 (- 1 ?cf1)))))
)

;combine NEGATIVE cf
;cf(cf1,cf2) = cf1 + cf2 * (1 + cf1)

(defrule combine-neg-cf
 (declare (salience -1))
  ?f1 <- (current_goal   (goal ?g)(cf ?cf1&:(< ?cf1 0)))
  ?f2 <- (working_goal (goal ?g)(cf ?cf2&:(< ?cf2 0)))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(+ ?cf1 (* ?cf2 (+ 1 ?cf1)))))
)

;combine one POSITIVE and one NEGATIVE
;cf(cf1,cf2) = (cf1 + cf2) / 1 - MIN[abs(cf1),abs(cf2)]

(defrule neg-pos-cf
 (declare (salience -1))
  ?f1 <- (current_goal (goal ?g) (cf ?cf1))
  ?f2 <- (working_goal (goal ?g) (cf ?cf2))
  (test (< (* ?cf1 ?cf2) 0))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(/ (+ ?cf1 ?cf2) (- 1 (min (abs ?cf1) (abs ?cf2))))))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Question Triggering Rule
;;; to trigger the next question
;;; by replacing the current question with next question(working question)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; define question template
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate current_question (slot question) (slot desc) (slot option1) (slot option2) (slot option3) (slot option4))

(deftemplate working_question (slot question) (slot desc) (slot option1) (slot option2) (slot option3) (slot option4))

(defglobal ?*age* = 0
    ?*pregnant* = 0
    ?*ogtt* = 0
    ?*fpg* = 0
    ?*cpg* = 0
    ?*bmi* = 0)

;;;******************************************************************************************
;;;* QUERY INFO *
;;;******************************************************************************************

(defrule collect-info-gender
  (declare (salience 10))
  (info-gender male)
  ; (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
  (assert (info-pregnant no))
)

(defrule collect-info-pregnant-yes
  ; (declare (salience 10))
  (info-gender female)
  (info-pregnant yes)
  (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
  (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
  (bind ?*pregnant* 1)
)

(defrule collect-info-pregnant-no
  ; (declare (salience 10))
  (info-gender female)
  (info-pregnant no)
  (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
  (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2)))) 
  (bind ?*pregnant* 0)
)

(defrule collect-info-age
  (declare (salience 10))
  (info-age ?)
  ; (info-age 40)
  (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
  (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
  =>
  (if and ((numberp ?*age*) (> ?*age* 0))
    then
      (assert (info-age yes))
    else
      (assert (info-age no))
  )
  ;(if (and (>= ?*age* 20) (< ?*age* 40))
  ;    then
  ;    (assert (info-age yes))
      ; (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
  ;)
  ;(if (>= ?*age* 40)
  ;    then
  ;    (assert (info-age yes))
      ; (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
  ;    else
  ;    (assert (info-age no))
  ;)
)

;;;******************************************************************************************
;;;* QUERY TEST RESULS *
;;;******************************************************************************************

(defrule collect-ogtt-pregnant
    (not (test-ogtt ?))
    (info-pregnant yes)
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (numberp ?*ogtt*)
        then
          (if (> (float ?*ogtt*) 7.7)
            then
            (assert (test-ogtt unhealthy))
            (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 1.0))))
            else
            (assert (test-ogtt healthy))
            (assert (working_goal (goal gestational-diabetes) (cf (* ?cf-gestational -1.0))))
          )
        else (assert (test-ogtt not-available))
        (printout t crlf "not a")
    )
)

(defrule collect-ogtt-non-pregnant
    (not (test-ogtt ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (if (numberp ?*ogtt*)
        then
          (if (< (float ?*ogtt*) 11.1)
            then 
              (assert (test-ogtt healthy)) 
              (if (< ?*age* 20) then 
                (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8)))) 
                else 
                (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8)))) 
              ) 
            else
            (assert (test-ogtt unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
            )
          )
        else (assert (test-ogtt not-available))
    )
)

(defrule collect-fpg
    (not (test-fpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (if (numberp ?*fpg*)
        then
          (if (> (float ?*fpg*) 7.0) then
            (assert (test-fpg unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
            )
          )
          (if (and (>= (float ?*fpg*) 6.1) (<= (float ?*fpg*) 6.9)) then
            (assert (test-fpg at-risk))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
            )
          )
          (if (< (float ?*fpg*) 6.1) then 
            (assert (test-fpg healthy)))
            (if (< ?*age* 20) then 
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8)))) 
              else
                (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8))))
            )
        else (assert (test-fpg not-available))
    )
)

(defrule collect-cpg
    (not (test-cpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (if (numberp ?*cpg*)
        then
          (if (< (float ?*cpg*) 11.1)
            then 
              (assert (test-cpg healthy))
              (if (< ?*age* 20) then 
                (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8)))) 
                else 
                  (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8)))) 
              )
            else
            (assert (test-cpg unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
            )
          )
        else (assert (test-cpg not-available))
    )
)

(defrule assert-test-pregnant-gestational
  (declare (salience -8))
  (info-pregnant yes)
  (test-ogtt unhealthy)
  =>
  (assert (result-test gestational))
)

(defrule assert-test-pregnant-healthy
  (declare (salience -8))
  (info-pregnant yes)
  (test-ogtt healthy)
  =>
  (assert (result-test healthy))
)

(defrule assert-test-non-pregnant-unhealthy
  (declare (salience -8))
  (info-pregnant no)
  (or
     (and (test-fpg unhealthy) (test-ogtt unhealthy))
     (and (test-fpg unhealthy) (test-cpg unhealthy))
     (and (test-ogtt unhealthy) (test-cpg unhealthy))
  )
  =>
  (printout t crlf "test unhealthy  :")
  (assert (result-test unhealthy))
)

(defrule assert-test-non-pregnant-consideration
  (declare (salience -8))
  (info-pregnant no)
  (or
     (and (test-fpg unhealthy) (test-ogtt healthy) (test-cpg healthy))
     (and (test-fpg healthy) (test-ogtt unhealthy) (test-cpg healthy))
     (and (test-fpg healthy) (test-ogtt healthy) (test-cpg unhealthy))
     (and (test-fpg unhealthy) (test-ogtt not-available) (test-cpg not-available))
     (and (test-fpg not-available) (test-ogtt not-available) (test-cpg unhealthy))
     (and (test-fpg not-available) (test-ogtt unhealthy) (test-cpg not-available))
     (and (test-fpg healthy) (test-ogtt not-available) (test-cpg not-available))
     (and (test-fpg not-available) (test-ogtt not-available) (test-cpg healthy))
     (and (test-fpg not-available) (test-ogtt healthy) (test-cpg not-available))
  )
  =>
  (printout t crlf "test consideration :")
  (assert (result-test consideration))
)

(defrule assert-test-non-pregnant-healthy
  (declare (salience -8))
  (info-pregnant no)
  (or (test-fpg healthy) (test-fpg at-risk))
  (test-ogtt healthy)
  (test-cpg healthy)
  =>
  (printout t crlf "test healthy :")
  (assert (result-test healthy))
)

(defrule assert-test-non-pregnant-healthy-alternative
  (declare (salience -8))
  (info-pregnant no)
  (or
     (and (test-fpg healthy) (test-ogtt healthy) (test-cpg not-available))
     (and (test-fpg healthy) (test-ogtt not-available) (test-cpg healthy))
     (and (test-fpg not-available) (test-ogtt healthy) (test-cpg healthy))
  )
  =>
  (printout t crlf "at least 2 test healthy, 1 test not available")
  (assert (result-test healthy))
)

(defrule assert-test-collected
  (declare (salience -8))
  (or
    (test-fpg ?)
    (test-ogtt ?)
    (test-cpg ?)
  )
  =>
  (assert (at-least-one-test yes))
)

;;;******************************************************************************************
;;;* QUERY RISK FACTORS *
;;;******************************************************************************************
(defrule collect-obesity
    (not (factor-obesity ?))
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (numberp ?*bmi*) then
      (assert (at-least-one-factor yes))
      (if (>= (float ?*bmi*) 30) then
        (assert (factor-obesity obesity))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.6))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.6))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.6))))
        (assert (result-factor at-risk)) 
      )
      (if (and (>= (float ?*bmi*) 25) (<= (float ?*bmi*) 29.9)) then
        (assert (factor-obesity overweight))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.5))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.5))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.5))))
      )
      (if (< (float ?*bmi*) 25) then 
        (assert (factor-obesity normal))
        (if (< ?*age* 20) then 
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.6)))) 
          else 
            (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.6)))) 
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.6)))) 
      )  
      else (assert (factor-obesity not-available))
    )
)

(defrule collect-blood-pressure-yes
    (factor-bp yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (factor-bp high))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-factor at-risk)) 
)

(defrule collect-blood-pressure-no
    (factor-bp no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (factor-bp normal))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-family-history-yes
    (factor-history yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-factor at-risk)) 
)

(defrule collect-family-history-no
    (factor-history no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-triglycerides-n
    (factor-tg n)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (assert (factor-tg normal))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-triglycerides-b
    (factor-tg b)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (assert (factor-tg borderline))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
)

(defrule collect-triglycerides-h
    (factor-tg h)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (assert (factor-tg high))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.5))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.5))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.5))))
    (assert (result-factor at-risk)) 
)

(defrule collect-gestational-history-yes
    (factor-gestational-history yes)
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.6))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.6))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.6))))
    (assert (result-factor at-risk)) 
)

(defrule collect-gestational-history-no
    (factor-gestational-history no)
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.6))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.6))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.6))))
)

(defrule collect-activity-no
    (factor-activity no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (factor-activity yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-factor at-risk)) 
)

(defrule collect-activity-yes
    (factor-activity yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (factor-activity no))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-glucose-tolerance-yes
    (factor-gt yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-factor at-risk)) 
)

(defrule collect-glucose-tolerance-no
    (factor-gt no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-pos-yes
    (factor-pos yes)
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-factor at-risk)) 
)

(defrule collect-pos-no
    (factor-pos no)
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-factor yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

;;;******************************************************************************************
;;;* QUERY SYMPTOMS *
;;;******************************************************************************************

(defrule collect-headache-yes
    (symp-headache yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes)) 
)

(defrule collect-headache-no
    (symp-headache no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-blur-yes
    (symp-blur yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes)) 
)

(defrule collect-blur-no
    (symp-blur no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-excessive-urination-yes
    (symp-eu yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes)) 
)

(defrule collect-excessive-urination-no
    (symp-eu no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-polydipsia-yes
    (symp-polydipsia yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes)) 
)

(defrule collect-polydipsia-no
    (symp-polydipsia no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-lost-consciousness-yes
    (symp-lc yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes))
)

(defrule collect-lost-consciousness-no
    (symp-lc no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-nausea-yes
    (symp-nausea yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes))
)

(defrule collect-nausea-no
    (symp-nausea no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-polyphagia-yes
    (symp-polyphagia yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes))
)

(defrule collect-polyphagia-no
    (symp-polyphagia no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-tiredness-yes
    (symp-tiredness yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes))
)

(defrule collect-tiredness-no
    (symp-tiredness no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-lose-weight-yes
    (symp-lw yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes))

)

(defrule collect-lose-weight-no
    (symp-lw no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-fraction-yes
    (symp-fraction yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes))
)

(defrule collect-fraction-no
    (symp-fraction no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-infection-yes
    (symp-infection yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
    (assert (result-symtom diabetes))
)

(defrule collect-infection-no
    (symp-infection no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (assert (at-least-one-symptom yes))
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
)

(defrule collect-loss-sensation-yes
    (symp-ls yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
    (assert (result-symtom diabetes))
)

(defrule collect-loss-sensation-no
    (symp-ls no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
)

(defrule collect-cold-sweat-yes
    (symp-cs yes)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
)

(defrule collect-cold-sweat-no
    (symp-cs no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    (if (< ?*age* 20) then
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
      else
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
    )
    (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
    (assert (result-symtom diabetes)) 
)

;;;******************************************************************************************
;;;* RESULTS *
;;;******************************************************************************************
(defrule compile_recommendation-at-risk
  (declare (salience -9))
  (current_fact (fact at-risk) (cf ?cf-at-risk))
  (result-test healthy)
  (result-factor at-risk)
  =>
  (assert (working_goal (goal at-risk) (cf (+ ?cf-at-risk 1.0))))
)

(defrule compile_recommendation-consideration-1
  (declare (salience -9))
  (current_fact (fact more-consideration) (cf ?cf-more-consideration))
  (result-test healthy)
  (result-symtom diabetes)
  (not (result-factor ?)) 
  =>
  (printout t crlf "consideration 1 :")
  (assert (working_goal (goal more-consideration) (cf (+ ?cf-more-consideration 1.0))))
)

(defrule compile_recommendation-consideration-2
  (declare (salience -9))
  (current_fact (fact more-consideration) (cf ?cf-more-consideration))
  (result-test unhealthy)
  (not (result-symtom ?))
  =>
  (printout t crlf "consideration 2 :")
  (assert (working_goal (goal more-consideration) (cf (+ ?cf-more-consideration 1.0))))
)

(defrule compile_recommendation-consideration-3
  (declare (salience -9))
  (current_fact (fact more-consideration) (cf ?cf-more-consideration))
  (result-test consideration) 
  =>
  (printout t crlf "consideration 3 :")
  (assert (working_goal (goal more-consideration) (cf (+ ?cf-more-consideration 1.0))))
)

(defrule compile_recommendation-consideration-4
  (declare (salience -9))
  (current_fact (fact more-consideration) (cf ?cf-more-consideration))
  (not (result-test ?))
  (or (result-symtom diabetes) (result-factor at-risk))
  =>
  (printout t crlf "consideration 4 :")
  (assert (working_goal (goal more-consideration) (cf (+ ?cf-more-consideration 1.0))))
)

(defrule compile_recommendation-information-unavailable
  (declare (salience -9))
  (not (at-least-one-test yes))
  (not (at-least-one-factor yes))
  (not (at-least-one-symptom yes))
  =>
  (printout t crlf "not enough information :")
)

(defrule compile_recommendation-healthy
  (declare (salience -9))
  (current_fact (fact healthy) (cf ?cf-healthy))
  (result-test healthy)
  (not (result-symtom ?))
  (not (result-factor ?))
  =>
  (assert (working_goal (goal healthy) (cf (+ ?cf-healthy 1.0))))
)

(defrule compile_results
	(declare (salience -10))
	(current_goal (goal healthy) (cf ?cf-healthy))
	(current_goal (goal at-risk) (cf ?cf-risk))
	(current_goal (goal diabetes-type-I) (cf ?cf-diabetes-I))
	(current_goal (goal diabetes-type-II) (cf ?cf-diabetes-II))
	(current_goal (goal gestational-diabetes) (cf ?cf-gestational))
  (current_goal (goal more-consideration) (cf ?cf-consideration))
=>
  (if (= ?*pregnant* 0) then
      (printout t crlf "Diabetes Diagnosis result :")
      (printout t crlf)
      (printout t crlf "Healthy: " (float (* ?cf-healthy 100)) "%")
      (printout t crlf "At Risk   : " (float (* ?cf-risk 100)) "%")
      (printout t crlf "Diabetes I   : " (float (* ?cf-diabetes-I 100)) "%")
      (printout t crlf "Diabetes II    : " (float (* ?cf-diabetes-II 100)) "%")
      (printout t crlf "Gestational diabetes    : 0.0%" crlf)
      (printout t crlf "Further medial consulation    : " (float (* ?cf-consideration 100)) "%" crlf)
    else
      (printout t crlf "Diabetes Diagnosis result :")
      (printout t crlf)
    	(printout t crlf "Healthy: " (float (* ?cf-healthy 100)) "%")
    	(printout t crlf "At Risk   : " (float (* ?cf-risk 100)) "%")
    	(printout t crlf "Diabetes I   : " (float (* ?cf-diabetes-I 100)) "%")
    	(printout t crlf "Diabetes II    : " (float (* ?cf-diabetes-II 100)) "%")
      (printout t crlf "Gestational diabetes    : " (float (* ?cf-gestational 100)) "%" crlf)
    	(printout t crlf "Further medical consultation    : " (float (* ?cf-consideration 100)) "%" crlf)
  )
)
