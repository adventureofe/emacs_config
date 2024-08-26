;; make garbage collection happen fewer times
(setq gc-cons-threshold (* 100 1000 1000))

;;print startup info
(add-hook 'emacs-startup-hook
		      #'(lambda ()
			      (message "Startup in %s with %d garbage collections"
					       (emacs-init-time "%.2f")
					       gcs-done)))

(defvar elpaca-installer-version 0.7)
  (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
  (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
  (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
  (defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
								:ref nil :depth 1
								:files (:defaults "elpaca-test.el" (:exclude "extensions"))
								:build (:not elpaca--activate-package)))
  (let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
		 (build (expand-file-name "elpaca/" elpaca-builds-directory))
		 (order (cdr elpaca-order))
		 (default-directory repo))
	(add-to-list 'load-path (if (file-exists-p build) build repo))
	(unless (file-exists-p repo)
	  (make-directory repo t)
	  (when (< emacs-major-version 28) (require 'subr-x))
	  (condition-case-unless-debug err
		  (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
				   ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
												   ,@(when-let ((depth (plist-get order :depth)))
													   (list (format "--depth=%d" depth) "--no-single-branch"))
												   ,(plist-get order :repo) ,repo))))
				   ((zerop (call-process "git" nil buffer t "checkout"
										 (or (plist-get order :ref) "--"))))
				   (emacs (concat invocation-directory invocation-name))
				   ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
										 "--eval" "(byte-recompile-directory \".\" 0 'force)")))
				   ((require 'elpaca))
				   ((elpaca-generate-autoloads "elpaca" repo)))
			  (progn (message "%s" (buffer-string)) (kill-buffer buffer))
			(error "%s" (with-current-buffer buffer (buffer-string))))
		((error) (warn "%s" err) (delete-directory repo 'recursive))))
	(unless (require 'elpaca-autoloads nil t)
	  (require 'elpaca)
	  (elpaca-generate-autoloads "elpaca" repo)
	  (load "./elpaca-autoloads")))
  (add-hook 'after-init-hook #'elpaca-process-queues)
  (elpaca `(,@elpaca-order))

 ;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)   
(scroll-bar-mode -1)
(set-window-scroll-bars (minibuffer-window) nil nil)

(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(setq scroll-conservatively 10000)

(global-prettify-symbols-mode t)

(setq-default tab-width 4)

;; treat camelcase as separate words
(global-subword-mode 1)

(setq visible-bell t)

(setq use-short-answers t)

(blink-cursor-mode -1)

(show-paren-mode 1)
(setq show-paren-delay 0)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(prefer-coding-system 'utf-8)

(defun efs/run-in-background (command)
	(let ((command-parts (split-string command "[ ]+")))
		(apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(defun efs/exwm-update-class ()
	(exwm-workspace-rename-buffer exwm-class-name))

(defun efs/exwm-update-title ()
	(pcase exwm-class-name
		("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))))

(defun dw/exwm-init-hook ()
	;; Make workspace 1 be the one where we land at startup
	(exwm-workspace-switch-create 1))

 (defun efs/configure-window-by-class ()
	 (interactive)
	 (pcase exwm-class-name
		("Firefox" (exwm-workspace-move-window 2))
		("Sol" (exwm-workspace-move-window 3))
		("mpv" (exwm-floating-toggle-floating)
		(exwm-layout-toggle-mode-line))))

      ;; This function should be used only after configuring autorandr!
      (defun efs/update-displays ()
	      (efs/run-in-background "autorandr --change --force")
	      (efs/set-wallpaper)
	      (message "Display config: %s"
		      (string-trim (shell-command-to-string "autorandr --current"))))

      (use-package exwm
	  :ensure t
	  :demand t
	      :config
	      (setq exwm-workspace-number 4)

	      ;; When window "class" updates, use it to set the buffer name
	      (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

	      ;; When window title updates, use it to set the buffer name
	      (add-hook 'exwm-update-title-hook #'efs/exwm-update-title)

	      ;; Configure windows as they're created
	      (add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)

	      (setq exwm-input-prefixkeys
		      '(?\C-x
		      ?\C-u
		      ?\C-h
		      ?\M-x
		      ?\M-`
		      ?\M-&
		      ?\M-:
		      ?\C-\M-j
		      ?\C-\ ))

	      ;;ctrl + q will enable the next key to be sent directly
	      (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

	      (require 'exwm-randr)
	      ;; set workspaces to different screens
	      (setq exwm-randr-workspace-monitor-plist '(1 "DVI-D-0"))
	      (add-hook 'exwm-randr-screen-change-hook
		      (lambda ()
			      (start-process-shell-command "xrandr" nil "xrandr --output DVI-D-0 --left-of --output HDMI-0 --auto")))		
	      (exwm-randr-enable)


	      ;; set workspaces to different screens
	      (setq exwm-randr-workspace-monitor-plist '(2 "HDMI-0" 3 "HDMI-0"))

	      ;; Rebind CapsLock to Ctrl
	      (start-process-shell-command "xmodmap" nil "xmodmap ~/.config/emacs/Xmodmap")


	      ;; Load the system tray before exwm-init
	      (require 'exwm-systemtray)
	      (setq exwm-systemtray-height 32)
	      (exwm-systemtray-enable)

	      (setq exwm-input-global-keys
		      `(
			      ([?\s-r] . exwm-reset)
			      ([s-left] . windmove-left)
			      ([s-right]. windmove-right)
			      ([?\s-w] . exwm-workspace-switch)
			      ([?\s-&] . (lambda (command)
				      (interactive (list (read-shell-command "$ ")))
				      (start-process-shell-command command nil command)))

			      ;; Switch workspace
			      ([?\s-w] . exwm-workspace-switch)

			      ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
			      ,@(mapcar (lambda (i)
				      `(,(kbd (format "s-%d" i)) .
					      (lambda ()
						      (interactive)
						      (exwm-workspace-switch-create ,i))))
				      (number-sequence 0 9))))

	      (exwm-enable))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
      :ensure t
      :demand t
      :init ;;tweak evil's config before loading
      (setq evil-want-integration t) ;; this is optional since already set to true
      (setq evil-want-keybinding nil)
      (setq evil-vsplit-window-right t)
      (setq evil-split-window-below t)
      (setq evil-want-C-i-jump nil)
      (evil-mode) 
      (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state))

(use-package evil-collection
      :ensure t
      :demand t
      :after evil
      :config
      (setq evil-collection-mode-list '(dashboard dired ibuffer))
      (evil-collection-init))

(use-package evil-tutor
      :ensure t
      :demand t
      :after evil
      )

(use-package evil-org
      :ensure t
      :demand t
      :after org
      :hook (org-mode . (lambda () evil-org-mode))
      :config
      (require 'evil-org-agenda)
      (evil-org-agenda-set-keys))

(use-package cyberpunk-theme
      :ensure t
      :demand t
      :init (load-theme 'cyberpunk t))

(defun my-set-foreground-color (&optional frame)
  "Set custom foreground color."
  (with-selected-frame (or frame (selected-frame))
    (set-foreground-color "green")))

;; Run later, for client frames...
(add-hook 'after-make-frame-functions 'my-set-foreground-color)
;; ...and now, for the initial frame.
(my-set-foreground-color)

(use-package org-roam
      :ensure t
      :demand t
      :init
      (setq org-roam-v2-ack t)
      :custom
      (org-roam-directory "~/RoamNotes")
      (org-roam-completion-everywhere t)
      :bind (("C-c n l" . org-roam-buffer-toggle)
		 ("C-c n f" . org-roam-node-find)
		 ("C-c n i" . org-roam-node-insert)
		 :map org-mode-map
		 ("C-M-i"    . completion-at-point))
      :config
      (org-roam-setup))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
      :ensure t
      :demand t
:after org
:hook (org-mode . org-bullets-mode)
:custom
(org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●"))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package doom-modeline
  :ensure t
  :demand t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(setq backup-directory-alist '(("." . "~/MyEmacsBackups")))
(setq make-backup-files nil)
(setq auto-save-default nil)

(use-package which-key
  :ensure t
  :demand t
  :diminish which-key-mode
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

(use-package lsp-mode
  :ensure t
  :demand t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (python-mode . lsp)
         (typescript-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally, this makes errors show up on the right hand side of the screen
(use-package lsp-ui
  :ensure t
  :demand t
  :commands lsp-ui-mode)

;; to solve conflicts between company, yasnippet and tabbing
(defun company-yasnippet-or-completion ()
  (interactive)
  (let ((yas-fallback-behavior nil))
    (unless (yas-expand)
      (call-interactively #'company-indent-or-complete-common))))


    (use-package company
      :after lsp-mode
      :ensure t
      :demand t
      :hook lsp-mode
      :bind (:map company-active-map
                  ;; complete by pressing tab
                  ("<tab>" . company-yasnippet-or-completion)
                  ;; make it vimmy
                  ("C-j" . company-select-next)
                  ("C-k" . company-select-previous))
      (:map lsp-mode-map
            ("<tab>" . company-yasnippet-or-completion))
      :custom
      (company-minimum-prefix-length 1)
      ;;had issues with the x server crashing when using typescript lsp and this being at 0.1
      ;;changed it but don't know if that was the root cause yet
      (company-idle-delay 0.8))

    ;; company-box for a modern UI
;; makes a little box of completions
  (use-package company-box
    :ensure t
    :demand t
    :hook company-mode
    :custom-face
    (company-tooltip ((t (:inherit default :background "#000000"))))
    (company-tooltip-selection ((t (:inherit font-lock-function-name-face :background "#666666"))))
    (company-tooltip-common ((t (:inherit font-lock-constant-face))))
    (company-tooltip-annotation ((t (:inherit font-lock-builtin-face))))
    (company-scrollbar-bg ((t (:background "#444444"))))
    (company-scrollbar-fg ((t (:background "#888888")))))

(use-package yasnippet
  :ensure t
  :demand t
  :init
  (setq yas-snippet-dirs '("~/.config/emacs/snippets"))
  :config
  (yas-global-mode 1))

(set-face-attribute 'default nil :font "Iosevka" :height 130)

(use-package flycheck
:ensure t
:demand t
:init (global-flycheck-mode))

(use-package typescript-mode
  :ensure t
  :demand t
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 4))
