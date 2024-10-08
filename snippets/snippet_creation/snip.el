;;; package --- summary

;;; Commentary:

;;; Code:
(defconst my-string "Emacs3")

(defun my-greeting (greeting)
  "Return a GREETING."
  (let ((start "Hello, ")
		(end "!\n"))
  (concat start greeting end)))

(defconst greeting (my-greeting my-string))

(message greeting) ;;display in minibuffer

(provide 'snip)
;;; snip.el ends here
