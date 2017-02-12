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


;;;***************
;;;* QUERY RULES *
;;;***************

;;;* QUERY INFO *

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
  (forall (info-gender ?collected)
          (info-pregnant ?collected))
  => (assert (collected-info yes))
  )

;;;* QUERY SYMPTOMS *
(defrule collect-symp-ex-urinate
  (not (result ?))
  (not (symp-ex-urinate ?))
  =>
  (assert (symp-ex-urinate (yes-or-no-p "Are you having excessive urination (yes/no)?")))
  )

(defrule collect-polydipsia
  (not (result ?))
  (not (symp-polydipsia ?))
  =>
  (assert (symp-polydipsia (yes-or-no-p "Are you having polydipsia (yes/no)?")))
  )

(defrule assert-symptoms
  (or (symp-ex-urinate yes)
      (symp-polydipsia yes))
  =>
  (assert (result-symptom yes))
)

(defrule collected-symptoms
  (forall (symp-ex-urinate ?collected)
          (symp-polydipsia ?collected))
  =>
  (assert (collected-symptoms yes))
)

(defrule result-ok ""
   (not (result ?))
   (collected-info yes)
   (collected-symptoms yes)
   (not (result-symptom yes))
   =>
   (assert (result "Healthy.")))

(defrule result-at-risk ""
   (not (result ?))
   (collected-info yes)
   (collected-symptoms yes)
   (result-symptom yes)
   =>
   (assert (result "At risk.")))




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