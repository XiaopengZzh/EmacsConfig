;;; init.el --- Load the full configuration

;; This file bootstraps the configuration, which is divided
;; into a number of other


;; 'add-to-list' is a Emacs lisp function used to add a item into a list
;; 'load-path' is special Emacs lisp variable, containing the directory list
;; to be searched when Emacs loads lisp file.
;; 'expand-file-name' expand the related path to absolute path
;; 'user-emacs-directory' is a predefined Emacs lisp variable, which points to
;; '.emacs.d' directory.

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; examine if the current OS is macOS.
;; define a const variable named '*is-a-mac*', users can use it in other
;; configuration files.
;; 'system-type' is Emacs lisp variable, refers to the notion of current OS.
;; for macOS, the notion is 'darwin'

(defconst *is-a-mac* (eq system-type 'darwin))

;; Adjust garbage collection thresholds during startup, and thereafter

;;(let (normal-gc-cons-threshold (* 20 1024 1024)))
;;(let (init-gc-cons-threshold (* 128 1024 1024)))
;;  (setq gc-cons-threshold init-gc-cons-threshold)
;;  (add-hook 'emacs-startup-hook
;;	    (lambda() (setq gc-cons-threshold normal-gc-cons-threshold))))

;;----------------------------

(setq inhibit-startup-message t)

(require 'package)
(setq package-enable-at-startup nil)
;;(add-to-list 'package-archives
;;	     '("melpa" . "https://melpa.org/packages/"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; 'package-installed-p' is a function, used to check if some package is
;; already installed. 'package-refresh-contents' is a function used to
;; refresh the contents of package repository. 'package-install' is a
;; function used to install a speicified package.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; delete try package.

(setq org-image-actual-width nil)

(setq auto-save-default nil)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(use-package good-scroll
  :ensure t
  :if window-system
  :init (good-scroll-mode))

;; don't use smart-mode-line, it causes lag in typing

;; Org-mode stuff
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;; prevent the window from scrolling horizontally when typing text that
;; exceeds the rightmost side of the window.
;; If we simply use (setq truncate-lines nil), this configuration will apply to plain text mode instead of org-mode
;; But we only use this in org mode(plain text mode already have this), so we should add the function to org-mode hook, which means executing this function upon opening org-mode.
(add-hook 'org-mode-hook (lambda() (setq truncate-lines nil)))

(setq org-startup-indented nil)

;;(use-package avy
;;  :ensure t
;;  :bind (("C-'" . 'avy-goto-char-timer)))

;; avoid using 'use-package', it may some bugs on key bindings configuration. 


;; swiper can be used to search current buffer for text
;; Avy can be used to search entire visible area for text
;; Entire visible area contains the current buffer and other buffers that
;; are being set with windows

;;(use-package ace-window
;;  :ensure t
;;  :bind (("C-x o" . 'ace-window)))

;; counsel package has two dependencies, swiper and ivy. If we download
;; counsel, the other two will be downloaded automatically.

;; ivy configuration
(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")

;; ivy global key bindings
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c s") 'ivy-switch-view)

(require 'swiper)
(global-set-key (kbd "C-s") 'swiper-isearch)

(require 'counsel)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)

;; projectile configuration

;; I am not sure if projectile is working in lsp-mode, I suspect that projectile is not helping me
;; to make a guess on where the project root is, instead that it is lsp-mode who are helping me
;; make a guess on where the project root is.
;; So here I will just use projectile to help me find the files in the project, mainly by fuzzy
;; search
(use-package projectile
  :ensure t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-track-known-projects-automatically nil))

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :config (counsel-projectile-mode))




;; lsp mode configuration

(defun efs/lsp-mode-setup()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(setq lsp-enable-snippet nil)
(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

;; company mode

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	      ("<tab>" . company-complete-selction))
  (:map lsp-mode-map
	("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 3)
  (company-idle-delay 0.0)
  (company-show-numbers t))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; lsp-ui

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))


;; quit dap mode, too unhuman configuration, use clion instead on macOS
;; dap-mode

;;(use-package dap-mode
;;  :commands dap-debug
;;  :config
;;  (dap-ui-mode 1)
;;  (dap-tooltip-mode 1)
;;  (tooltip-mode 1)
;;  (dap-ui-controls-mode 1))

;;(require 'dap-lldb)


;; org-download configuration, this allows us to yank images from another point.

;;(defun org-download-mymethod()
;;  concat (file-name-sans-extension (buffer-file-name)) "-imag")

;; use C-c C-x C-v to execute org-toggle-inline-images
;; download snipaste to help capture screen to clipboard
(use-package org-download
  :ensure t
  :config
  (add-hook 'dired-mode-hook 'org-download-enable)
  (setq org-download-method 'directory)
;; setq org-download-image-dir is not working at all, I don't know why  
;;  (setq-default org-download-image-dir (concat "./images/" (file-name-sans-extension (buffer-file-name))))
;;  (setq org-download-image-dir 'org-download-mymethod)
  (setq org-download-image-attr-list '("#+ATTR_ORG: :width 100px"))
;; image-actual-width 100 , I'm not sure if this is working. org-download-image-attr-list is working
  (setq image-actual-width 100)
  :bind (("C-M-p" . org-download-clipboard)))



;; auto parenthesis completion
(electric-pair-mode)

;; highlight another parenthesis under programming mode
(add-hook 'prog-mode-hook #'show-paren-mode)

;; refresh buffer upon file revised
(global-auto-revert-mode t)

;; typing in other text after text being selected will replace
;; the selected text
(delete-selection-mode t)

;; close auto file backup
(setq make-backup-files nil)

;; in programming mode, enable to fold code block up
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; show line number
(global-display-line-numbers-mode 1)

;;close toolbar
(tool-bar-mode -1)

;; close scroll when in graphical display
(when (display-graphic-p) (toggle-scroll-bar -1))

;; delete rainbow-delimiters

;; This sentence aims to allow other Emacs lisp file to access and load
;; this configuration file
;; provide a notion 'init' to Emacs load system, this notion generally
;; should be the same as your filename.
;; allow other files to load : Through this notion, other Emacs lisp file
;; could use 'require' or 'load' to load this configuration file
;; This helps Emacs to split the configuration to different modules, which
;; is much more maintainable.
;; But for init.el, so far I don't think other configuration file would
;; to load it.

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(org-attach-screenshot org-download dap-mode lsp-ui company-box company lsp-mode counsel-projectile projectile which-key org-bullets good-scroll counsel)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
