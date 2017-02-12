


;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction ask-question (?question $?allowed-values)   (printout t ?question)   (bind ?answer (read))   (if (lexemep ?answer)        then (bind ?answer (lowcase ?answer)))   (while (not (member ?answer ?allowed-values)) do      (printout t ?question)      (bind ?answer (read))      (if (lexemep ?answer)           then (bind ?answer (lowcase ?answer))))   ?answer)(deffunction yes-or-no-p (?question)   (bind ?response (ask-question ?question yes no y n))   (if (or (eq ?response yes) (eq ?response y))       then yes        else no))

(deffunction m-or-f-p (?question)
   (bind ?response (ask-question ?question male female m f))
   (if (or (eq ?response male) (eq ?response m))
       then male 
       else female))


;;;***************
;;;* QUERY RULES *
;;;***************

(defrule collect-basic-info ""
  (not (info-gender ?))
  (not (result ?))
  =>
  (assert (info-gender (m-or-f-p "What is your gender (Male(M)/Female(F))? "))))  (defrule collect-pregnant-state  (info-gender female)  (not (info-pregnant ?))  (not (result ?))  =>  (assert (info-pregnant (yes-or-no-p "Are you pregnant (yes/no)?"))))(defrule result-ok ""   (or      (info-gender male)     (and (info-gender female)          (info-pregnant no)     )   )   (not (result ?))   =>   (assert (result "Healthy.")))




;;;********************************;;;* STARTUP AND CONCLUSION RULES *;;;********************************(defrule system-banner ""  (declare (salience 10))  =>  (printout t crlf crlf)  (printout t "The Diabetes Diagnosis Expert System")  (printout t crlf crlf))(defrule print-diagnosis ""  (declare (salience 10))  (result ?status)  =>  (printout t crlf crlf)  (printout t "Suggested Diagnosis result:")  (printout t crlf crlf)  (format t " %s%n%n%n" ?status))