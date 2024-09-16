(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))

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

(setq backup-directory-alist '(("." . "~/MyEmacsBackups")))
(setq make-backup-files nil)
(setq auto-save-default nil)

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

(use-package which-key
  :ensure t
  :demand t
  :diminish which-key-mode
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

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
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  :config
  (yas-global-mode 1))

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
