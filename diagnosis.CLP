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

;;; triggering the next question
(defrule next_question
	(declare (salience 100))
	?cq <- (current_question (question ?q1) )
	?wq <- (working_question (question ?q2) (desc ?desc) (option1 ?option1) (option2 ?option2) (option3 ?option3) (option4 ?option4))
 =>
	(retract ?wq)
	(modify ?cq  (question ?q2) (desc ?desc) (option1 ?option1) (option2 ?option2) (option3 ?option3) (option4 ?option4))
	(printout t "triggering the next question" crlf)
)

(defglobal ?*age* = 0
    ?*gender* = 0
    ?*pregnant* = 0
    ?*pregnant-input* = 0
    ?*ogtt* = 0
    ?*fpg* = 0
    ?*cpg* = 0
    ?*bmi* = 0
    ?*bp* = 0
    ?*fh* = 0
    ?*triglycerides* = 0
    ?*gh* = 0
    ?*activity* = 0
    ?*gt* = 0
    ?*pos* = 0
    ?*headache* = 0
    ?*blur* = 0
    ?*eu* = 0
    ?*polydipsia* = 0
    ?*lc* = 0
    ?*nausea* = 0
    ?*polyphagia* = 0
    ?*tiredness* = 0
    ?*lw* = 0
    ?*fraction* = 0
    ?*infection* = 0
    ?*ls* = 0
    ?*cs* = 0)

;;;******************************************************************************************
;;;* QUERY INFO *
;;;******************************************************************************************

(defrule collect-info-gender
  (declare (salience 10))
  (not (info-gender ?))
  =>
  ; (printout t crlf "What is your gender (Male(M)/Female(F))? ")
  ; (bind ?response (read))
  (if (or (eq ?*gender* male) (eq ?*gender* m))
      then
        (assert (info-gender male))
        (assert (info-pregnant no))
      else (assert (info-gender female))
    )
  )

(defrule collect-info-pregnant
  (info-gender female)
  (not (info-pregnant ?))
  (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
 ;  (printout t crlf "Are you pregnant (yes/no)? ")
	; (bind ?response (read))

  (switch ?*pregnant-input*
		(case yes then
				(assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (info-pregnant yes))
        (bind ?*pregnant* 1)
    )
		(case no then
        (assert (info-pregnant no))
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
        (bind ?*pregnant* 0)
    )
    (default (assert (info-pregnant no)))
	)
)

(defrule collect-info-age
  (declare (salience 10))
  (not (info-age ?))
  (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
  (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
  =>
  ; (printout t crlf "How old are you? ")
  ; (bind ?response (read))
  ; (bind ?*age* ?response)
  (if (and (>= ?*age* 20) (< ?*age* 40))
      then
      (assert (info-age yes))
      ;(assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
  )
  (if (>= ?*age* 40)
      then
      (assert (info-age yes))
      ;(assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
      else
      (assert (info-age no))
  )
)

;;;******************************************************************************************
;;;* QUERY TEST RESULS *
;;;******************************************************************************************

(defrule collect-ogtt-pregnant
    (not (test-ogtt ?))
    (info-pregnant yes)
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "How much is your blood glucose level (mmol/L) shown in 2-hours post Oral Glucose Tolerance test (OGTT) ? ")
    ; (bind ?response (read))
    (if (numberp ?*ogtt*)
        then
          (if (> (float ?*ogtt*) 7.7)
            then
            (assert (test-ogtt unhealthy))
            (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 1.0))))
            (printout t crlf "ogtt-pregnant unhealthy")
            else
            (assert (test-ogtt healthy))
            (assert (working_goal (goal gestational-diabetes) (cf (* ?cf-gestational -1.0))))
            (printout t crlf "ogtt-pregnant healthy")
          )
        else (assert (test-ogtt not-available))
        (printout t crlf "ogtt-pregnant not a")
    )
)

(defrule collect-ogtt-non-pregnant
    (not (test-ogtt ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    ; (printout t crlf "How much is your blood glucose level (mmol/L) shown in 2-hours post Oral Glucose Tolerance test (OGTT) ? ")
    ; (bind ?response (read))
    (if (numberp ?*ogtt*)
        then
          (if (< (float ?*ogtt*) 11.1)
            then
              (assert (test-ogtt healthy))
              (printout t crlf "ogtt-non-pregnant healthy")
              (printout t crlf ?*ogtt*)
              (if (< ?*age* 20) then
                (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8))))
                else
                (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8))))
              )
            else
              (assert (test-ogtt unhealthy))
              (printout t crlf "ogtt-non-pregnant unhealthy")
              (if (< ?*age* 20) then
                (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
                else
                (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
              )
          )
        else (assert (test-ogtt not-available))
        (printout t crlf "ogtt-non-pregnant not a")
    )
)

(defrule collect-fpg
    (not (test-fpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    ; (printout t crlf "How much is your blood glucose level (mmol/L) shown in Fasting Plasma Glucose test (FPG) ? ")
    ; (bind ?response (read))
    (if (numberp ?*fpg*)
        then
          (if (> (float ?*fpg*) 7.0) then
            (assert (test-fpg unhealthy))
            (printout t crlf "fpg unhealthy")
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
            )
          )
          (if (and (>= (float ?*fpg*) 6.1) (<= (float ?*fpg*) 6.9)) then
            (assert (test-fpg at-risk))
            (printout t crlf "fpg at-risk")
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
            )
          )
          (if (< (float ?*fpg*) 6.1) then
            (assert (test-fpg healthy))
            (printout t crlf "fpg healthy")
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8))))
            )
          )
        else (assert (test-fpg not-available))
        (printout t crlf "fpg not a")
    )
)

(defrule collect-cpg
    (not (test-cpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    ; (printout t crlf "How much is your blood glucose level (mmol/L) shown in Casual Plasma Glucose test (CPG) ? ")
    ; (bind ?response (read))
    (if (numberp ?*cpg*)
        then
          (if (< (float ?*cpg*) 11.1)
            then
              (assert (test-cpg healthy))
              (printout t crlf "cpg healthy")
              (if (< ?*age* 20) then
                (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.8))))
                else
                (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.8))))
              )
            else
            (assert (test-cpg unhealthy))
            (printout t crlf "cpg unhealthy")
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.8))))
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.8))))
            )
          )
        else (assert (test-cpg not-available))
        (printout t crlf "cpg not-a")
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
    ; (printout t crlf "How much is your Body Mass Index (BMI) ? ")
    ; (bind ?response (read))
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

(defrule collect-blood-pressure
    (not (factor-bp ?))
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have high blood pressure (>= 140/90 Mm Hg) (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*bp*
  		(case yes then
        (assert (factor-bp high))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-factor at-risk))
      )
      (case no then
        (assert (factor-bp normal))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
      (default (assert (factor-bp not-available)))
    )
)

(defrule collect-family-history
    (not (factor-history ?))
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have any family member has history of diabetes (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*fh*
  		(case yes then
        (assert (factor-history yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-factor at-risk))
      )
      (case no then
        (assert (factor-history no))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
      (default (assert (factor-history not-available)))
    )
)

(defrule collect-triglycerides
    (not (factor-tg ?))
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Is your triglyceride (body fat) at normal level (< 150mg/dL) or borderline high (150-199mg/dL) or high to very high (>200mg/dL) (n/b/h)? ")
    ; (bind ?response (read))
    (switch ?*triglycerides*
      (case n then
        (assert (at-least-one-factor yes))
        (assert (factor-tg normal))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
      (case b then
        (assert (at-least-one-factor yes))
        (assert (factor-tg borderline))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
      )
      (case h then
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
      (default (assert (factor-tg not-available)))
    )

)

(defrule collect-gestational-history
    (not (factor-gestational-history ?))
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have history of gestational diabetes or having baby with over 4kg (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*gh*
  		(case yes then
        (assert (at-least-one-factor yes))
        (assert (factor-gestational-history yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.6))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.6))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.6))))
        (assert (result-factor at-risk))
      )
      (case no then
        (assert (at-least-one-factor yes))
        (assert (factor-gestational-history no))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.6))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.6))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.6))))
      )
      (default (assert (factor-gestational-history not-available)))
    )
)

(defrule collect-activity
    (not (factor-activity ?))
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you excercise (do physical activity) at least 3 times per week (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*activity*
  		(case no then
        (assert (factor-activity yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-factor at-risk))
        ;(printout t crlf "don't exercise ")
      )
      (case yes then
        (assert (factor-activity no))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
      (default (assert (factor-activity not-available)))
    )
)

(defrule collect-glucose-tolerance
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have impaired Glucose Tolerance in previous tests (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*gt*
  		(case yes then
        (assert (at-least-one-factor yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-factor at-risk))
      )
      (case no then
        (assert (at-least-one-factor yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-pos
    (info-gender female)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have Polycystic Ovarian Syndrome (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*pos*
  		(case yes then
        (assert (at-least-one-factor yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-factor at-risk))
      )
      (case no then
        (assert (at-least-one-factor yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

;;;******************************************************************************************
;;;* QUERY SYMPTOMS *
;;;******************************************************************************************

(defrule collect-headache
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have headache (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*headache*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-blur
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you experience any blur of vision (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*blur*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-excessive-urination
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have excessive urination (the need to urinate more than you normally would, might occur along with bladder discomfort) (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*eu*
  		(case yes then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-polydipsia
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have polydipsia (excessive thirst) (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*polydipsia*
  		(case yes then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-lost-consciousness
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you experience losing consciousness (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*lc*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-nausea
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have symptom of nausea and vomitting (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*nausea*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-polyphagia
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you experience polyphagia or hyperphagia (excessive hunger or abnormally consumption of large quantities of food) (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*polyphagia*
  		(case yes then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-tiredness
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you experience tiredness (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*tiredness*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-lose-weight
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Are you losing weight without reason (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*lw*
  		(case yes then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-fraction
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have any fraction and skin tag (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*fraction*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-infection
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have frequent infections (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*infection*
  		(case yes then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.4))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (assert (at-least-one-symptom yes))
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.4))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.4))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.4))))
      )
    )
)

(defrule collect-loss-sensation
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have experience loss of sensation in hands and feet (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*ls*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
)

(defrule collect-cold-sweat
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    =>
    ; (printout t crlf "Do you have experience cold sweat (sudden sweating not due to exertion or heat) (yes/no)? ")
    ; (bind ?response (read))
    (switch ?*cs*
  		(case yes then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.2))))
        (assert (result-symtom diabetes))
      )
      (case no then
        (if (< ?*age* 20) then
          (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I -0.2))))
          else
          (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II -0.2))))
        )
        (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational -0.2))))
      )
    )
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
  (printout t crlf "===============================================================")
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
    	(printout t crlf "Further medial consulation    : " (float (* ?cf-consideration 100)) "%" crlf)
  )
)
