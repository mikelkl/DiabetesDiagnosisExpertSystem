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

(defrule collect-info-age
  (not (info-age ?))
  (not (result ?))
  =>
  (assert (info-age (yes-or-no-p "Are you >=20 years old (yes/no)?"))))


(defrule collected-info
   (info-gender ?)
   (info-pregnant ?)
   (info-age ?)
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
;;;* QUERY TEST RESULS *
;;;******************************************************************************************

(defrule collect-fpg
    (not (result ?))
    (not (test-fpg ?))
    (info-pregnant no)
    =>
    (assert (test-fpg (yes-or-no-p "Is your Fasting Plasma Glucose (FPG) test showing >= 7.0mmol/l (yes/no)?")))
)

(defrule collect-cpg
    (not (result ?))
    (not (test-cpg ?))
    (info-pregnant no)
    =>
    (assert (test-cpg (yes-or-no-p "Is your Casual Plasma Glucose (FPG) test showing >= 11.1mmol/l (yes/no)?")))
)

(defrule collect-ogtt-non-pregnant
    (not (result ?))
    (not (test-ogtt ?))
    (info-pregnant no)
    =>
    (assert (test-ogtt (yes-or-no-p "Is your 2-hour post Oral Glucose Tolerance (OGTT) test showing >= 11.1mmol/l (yes/no)?")))
)

(defrule collect-ogtt-pregnant
    (not (result ?))
    (not (test-ogtt ?))
    (info-pregnant yes)
    =>
    (assert (test-ogtt (yes-or-no-p "Is your 2-hour post Oral Glucose Tolerance (OGTT) test showing >= 7.8mmol/l (yes/no)?")))
)

(defrule collected-tests-pregnant
  (info-pregnant yes)
  (test-ogtt ?)
  =>
  (assert (collected-tests yes))
)

(defrule collected-tests-non-pregnant
  (info-pregnant no)
  (test-cpg ?)
  (test-fpg ?)
  (test-ogtt ?)
  =>
  (assert (collected-tests yes))
)

(defrule assert-test-pregnant-gestational
  (info-pregnant yes)
  (test-ogtt yes)
  =>
  (assert (result-test gestational))
)

(defrule assert-test-pregnant-healthy
  (info-pregnant yes)
  (test-ogtt no)
  =>
  (assert (result-test healthy))
)

(defrule assert-test-non-pregnant-unhealthy
  (info-pregnant no)
  (or
     (and (test-fpg yes) (test-ogtt yes))
     (and (test-fpg yes) (test-cpg yes))
  )
  =>
  (assert (result-test unhealthy))
)

(defrule assert-test-non-pregnant-consideration
  (info-pregnant no)
  (or
     (and (test-fpg yes) (test-ogtt no) (test-cpg no))
     (and (test-fpg no) (test-ogtt yes) (test-cpg no))
     (and (test-fpg no) (test-ogtt no) (test-cpg yes))
  )
  =>
  (assert (result-test consideration))
)

(defrule assert-test-non-pregnant-healthy
  (info-pregnant no)
  (test-fpg no)
  (test-ogtt no)
  (test-cpg no)
  =>
  (assert (result-test healthy))
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
   (collected-tests yes)
   (not (result-symptom yes))
   (not (result-factors yes))
   (result-tests healthy)
   =>
   (assert (result "Healthy.")))

(defrule result-at-risk-1 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (not (result-symptom yes))
      (result-factors yes)
      (result-tests healthy)
      =>
      (assert (result "Showing some risk factors. Test ok. At Risk.")))

(defrule result-at-risk-2 ""
   (declare (salience -10))
   (not (result ?))
   (collected-info yes)
   (collected-symptoms yes)
   (collected-factors yes)
   (collected-tests yes)
   (result-symptom yes)
   (result-factors yes)
   (result-tests healthy)
   =>
   (assert (result "Showing symptoms and risk factors. Test ok. At risk.")))

(defrule result-more-consider ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom yes)
      (not (result-factors yes))
      (result-tests healthy)
      =>
      (assert (result "Showing symptoms but having no risk factors. Need more consideration.")))

(defrule result-diabetes-1 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom yes)
      ;(not (result-factors yes))
      (result-tests unhealthy)
      (info-pregnant no)
      (info-age no)
      =>
      (assert (result "Non-pregnant, less than 20 yrs old. Diabetes symptoms. Failed at least 2 tests. Diabetes Type I")))

(defrule result-diabetes-2 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom yes)
      ;(not (result-factors yes))
      (result-tests unhealthy)
      (info-pregnant no)
      (info-age yes)
      =>
      (assert (result "Non-pregnant, >=20 yrs old. Diabetes symptoms. Failed at least 2 tests. Diabetes Type II")))

(defrule result-diabetes-gestational ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom yes)
      ;(not (result-factors yes))
      (result-tests gestational)
      (info-pregnant yes)
      =>
      (assert (result "Pregnant. Diabetes symptoms. Test show unhealthy gestational. Gestational Diabetes")))

(defrule result-consideration-1 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom no)
      ;(not (result-factors yes))
      (result-tests gestational)
      (info-pregnant yes)
      =>
      (assert (result "Pregnant. No Diabetes symptoms. Test show unhealthy gestational. More consideration")))

(defrule result-consideration-2 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom no)
      ;(not (result-factors yes))
      (result-tests unhealthy)
      (info-pregnant no)
      =>
      (assert (result "No Pregnant. No Diabetes symptoms. Test show unhealthy. More consideration")))

(defrule  result-consideration-3 ""
   (declare (salience -10))
      (not (result ?))
      (collected-info yes)
      (collected-symptoms yes)
      (collected-factors yes)
      (collected-tests yes)
      (result-symptom no)
      ;(not (result-factors yes))
      (result-tests consideration)
      (info-pregnant no)
      =>
      (assert (result "No Pregnant. No Diabetes symptoms. Test show more consideration. More consideration")))

;;;********************************
;;;* STARTUP AND CONCLUSION RULES *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "The Diabetes Diagnosis Expert System Ble Ble Ble")
  (printout t crlf crlf))

(defrule print-diagnosis ""
  (declare (salience 10))
  (result ?status)
  =>
  (printout t crlf crlf)
  (printout t "Suggested Diagnosis result:")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?status))
