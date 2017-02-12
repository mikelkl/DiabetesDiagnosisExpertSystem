;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer)
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer)
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then yes
       else no))

(deffunction m-or-f-p (?question)
   (bind ?response (ask-question ?question male female m f))
   (if (or (eq ?response male) (eq ?response m))
       then male
       else female))

;;;******************************************************************************************
;;;* QUERY INFO *
;;;******************************************************************************************

(defrule collect-info-gender ""
  (not (info-gender ?))
  (not (result ?))
  =>
  (assert (info-gender (m-or-f-p "What is your gender (Male(M)/Female(F))? "))))


(defrule collect-info-pregnant
  (info-gender female)
  (not (info-pregnant ?))
  (not (result ?))
  =>
  (assert (info-pregnant (yes-or-no-p "Are you pregnant (yes/no)?"))))

(defrule collect-info-pregnant-default
  (info-gender male)
  (not (result ?))
  =>
  (assert (info-pregnant no))
  )

  (defrule collected-info
     (info-gender ?)
     (info-pregnant ?)
    => (assert (collected-info yes))
    )

;;;******************************************************************************************
;;;* QUERY SYMPTOMS *
;;;******************************************************************************************

(defrule collect-symp-ex-urinate
  (not (result ?))
  (not (symp-ex-urinate ?))
  =>
  (assert (symp-ex-urinate (yes-or-no-p "Symptoms check: Are you having excessive urination (yes/no)?")))
  )

(defrule collect-polydipsia
  (not (result ?))
  (not (symp-polydipsia ?))
  =>
  (assert (symp-polydipsia (yes-or-no-p "Symptoms check: Are you having polydipsia - increased thirst (yes/no)?")))
  )

(defrule collect-polyphagia
    (not (result ?))
    (not (symp-polyphagia ?))
    =>
    (assert (symp-polyphagia (yes-or-no-p "Symptoms check: Are you having polyphagia - feeling hungry (yes/no)?")))
    )

(defrule collect-tiredness
    (not (result ?))
    (not (symp-tiredness ?))
    =>
    (assert (symp-tiredness (yes-or-no-p "Symptoms check: Are you feeling any tired (yes/no)?")))
)

(defrule collect-lose-weight
    (not (result ?))
    (not (symp-lose-weight ?))
    =>
    (assert (symp-lose-weight (yes-or-no-p "Symptoms check: Are you losing weight without any reason (yes/no)?")))
)

(defrule collect-infection
    (not (result ?))
    (not (symp-infection ?))
    =>
    (assert (symp-infection (yes-or-no-p "Symptoms check: Are you having frequent infections (yes/no)?")))
)

(defrule assert-symptoms
  (or (symp-ex-urinate yes)
      (symp-polydipsia yes)
      (symp-polyphagia yes)
      (symp-tiredness yes)
      (symp-lose-weight yes)
      (symp-infection yes)
  )
  =>
  (assert (result-symptom yes))
)

(defrule collected-symptoms
  (symp-ex-urinate ?)
  (symp-polydipsia ?)
  (symp-polyphagia ?)
  (symp-tiredness ?)
  (symp-lose-weight ?)
  (symp-infection ?)
  =>
  (assert (collected-symptoms yes))
)

;;;******************************************************************************************
;;;* QUERY RISK FACTORS *
;;;******************************************************************************************

(defrule collect-obesity
    (not (result ?))
    (not (factor-obesity ?))
    =>
    (assert (factor-obesity (yes-or-no-p "Risk Factors check: Are you having obesity (yes/no)?")))
)

(defrule collect-gestational
    (not (result ?))
    (not (factor-gestational ?))
    (info-gender female)
    =>
    (assert (factor-gestational (yes-or-no-p "Risk Factors check: Do you have history of gestational diabetes or having baby with over 4Kg weight (yes/no)?")))
)

(defrule collect-gestational-default
    (not (result ?))
    (info-gender male)
    =>
    (assert (factor-gestational no))
)

(defrule collected-factors
  (factor-obesity ?)
  (factor-gestational ?)
  =>
  (assert (collected-factors yes))
)

(defrule assert-risk-factors
  (or (factor-obesity yes)
      (factor-gestational yes)
  )
  =>
  (assert (result-factors yes))
)


;;;******************************************************************************************
;;;* ASSERT RESULTS *
;;;******************************************************************************************

(defrule result-ok ""
   (declare (salience -10))
   (not (result ?))
   (collected-info yes)
   (collected-symptoms yes)
   (collected-factors yes)
   (not (result-symptom yes))
   (not (result-factors yes))
   =>
   (assert (result "Healthy.")))

(defrule result-at-risk-1 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (not (result-symptom yes))
      (result-factors yes)
      =>
      (assert (result "Showing some risk factors. At Risk.")))

(defrule result-at-risk-2 ""
   (declare (salience -10))
   (not (result ?))
   (collected-info yes)
   (collected-symptoms yes)
   (collected-factors yes)
   (result-symptom yes)
   (result-factors yes)
   =>
   (assert (result "Showing symptoms and risk factors. At risk.")))

(defrule result-more-consider ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (result-symptom yes)
      (not (result-factors yes))
      =>
      (assert (result "Showing symptoms but having no risk factors. Need more consideration.")))

;;;********************************
;;;* STARTUP AND CONCLUSION RULES *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "The Diabetes Diagnosis Expert System")
  (printout t crlf crlf))

(defrule print-diagnosis ""
  (declare (salience 10))
  (result ?status)
  =>
  (printout t crlf crlf)
  (printout t "Suggested Diagnosis result:")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?status))
