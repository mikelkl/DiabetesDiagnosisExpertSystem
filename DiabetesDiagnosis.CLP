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