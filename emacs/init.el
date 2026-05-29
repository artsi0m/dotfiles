;; coping with codepages on MS windows
;; This part should be loaded before reading org files
;; to make it possible to read 1/3
(defvar *fs-encoding* 'utf-8)
(prefer-coding-system 'utf-8-unix)

;; 2/4 variables set by custom
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

;; 3/4

;; layout
(load-file
 (expand-file-name "cyrillic-colemak.el" user-emacs-directory))

(setq default-input-method "cyrillic-colemak")


(setq use-package-compute-statistics 't)

;; For more information, please refer to <http://unlicense.org>
(use-package files
    :custom
    (backup-directory-alist `(("." . "~/.cache/emacs/backups")))
    (backup-by-copying t))


;; (use-package reverse-im
;;   :ensure t
;;   :init (reverse-im-mode)
;;   :custom
;;   (reverse-im-input-methods '("cyrillic-colemak"))
;;   (reverse-im-cache-file "~/.cache/emacs/reverse-im-cache.el"))


(use-package frames-only-mode
  :bind ("C-x 5 9" . frames-only-mode))

(use-package ispell
  :commands (ispell ispell-region ispell-word)
  :config
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,ru_RU")
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary "en_US,ru_RU")
  (ispell-personal-dictionary "~/howm/.hunspell_personal"))
(setopt icon-map-list nil) ;; build in icons

(tab-bar-mode) ;; tab bar mode by default

(which-key-mode) ;; key suggestions

(global-visual-line-mode)

(use-package modus-themes
  :init (load-theme 'modus-operandi)
  :when (not (eq window-system nil)))
;; Press C-M-i to activate emacs autocomplete.

;; Frankly speaking, I copy this snippet from the official vertico docs:

;; https://github.com/minad/vertico?tab=readme-ov-file#completion-at-point-and-completion-in-region

;; This configuration give my ability to perform fuzzy search.
;; Like with dmenu, rofi or fzf, but in emacs.

(use-package vertico
  :init (vertico-mode)
     (setq completion-in-region-function
	   (lambda (&rest args)
	     (apply (if vertico-mode
			   #'consult-completion-in-region
		      #'completion--in-region)
		    args)))
     :ensure t)

(use-package consult :ensure t)

(use-package consult-eglot :commands (eglot) :ensure t)
(use-package dired
  :custom (dired-dwim-target t))
(use-package magit :commands (magit) :ensure t)

(use-package git-modes :ensure t)
(use-package howm
  :init (when (not (eq system-type 'windows-nt))
          (setq howm-view-use-grep t))
  :custom
  (howm-search-other-dir t)
  :ensure t)


(use-package howm-use-any-markup
  :vc (:url "https://github.com/artsi0m/howm-use-any-markup")
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flashcards using org-drill ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-drill
      :pin melpa
      :ensure t)


(defun my-org-drill-file-names-in-howm ()
  "Return list of absolute filenames of org-drill files in howm"
  (delete-dups
   (mapcar #'car (howm-grep "\:drill\:"
			    (howm-files-in-directory howm-directory)))))


(defun my-org-drill-set-scope ()
  (interactive)
  (let ((scope-var
	 (completing-read "Choose scope for org-drill: " (list
		   "howm"
		   "file"
		   "tree"
		   "file-no-restriction"
		   "agenda"
		   "agenda-with-archives"
		  "directory"))))
    (if (equal scope-var "howm")
	(setq org-drill-scope (my-org-drill-file-names-in-howm))
      (setq org-drill-scope (intern scope-var)))))


(define-advice org-drill (:before (&rest _args))
  (my-org-drill-set-scope))

(define-advice org-drill-cram (:before (&rest _args))
  (my-org-drill-set-scope))

(defun org-drill-time-to-inactive-org-timestamp (time)
  "Convert TIME into org-mode timestamp."
  (format-time-string
   (concat "[" (cdr org-time-stamp-formats) "]")
   time))

;; Use C locale for time. Needed for org-pomodoro on windows.A
(setq system-time-locale "C")

(use-package org-pomodoro
  :custom
  (org-pomodoro-keep-killed-pomodoro-time 't)
  (org-pomodoro-length 80)
  (org-pomodoro-short-break-length 15)
  (org-pomodoro-long-break-length 35)
  :ensure t)

(use-package org-pomodoro-third-time
  :vc (:url "git@github.com:telotortium/org-pomodoro-third-time.git")
  :init  (org-pomodoro-third-time-mode)
  :ensure t)

(use-package auctex
  :init (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil))

(setq-default TeX-engine 'luatex)
(use-package pyvenv
  :commands (pyvenv-activate pyvenv-workon))

(use-package pydoc :ensure t)
(use-package slime :commands (slime))

(when (executable-find "sbcl")
(setq inferior-lisp-program "sbcl"))
(use-package yaml-mode)

(use-package flymake-yamllint
  :when (executable-find "yamllint")
  :hook (yaml-mode . flymake-yamllint-setup)
  :ensure t)

(use-package docker-compose-mode)

(use-package ansible
    :hook (ansible-mode . whitespace-mode)
    :ensure t)

(use-package flymake-ansible-lint
  :when (executable-find "ansible-lint")
  :ensure t
  :commands flymake-ansible-lint-setup
  :hook (((ansible-mode) . flymake-ansible-lint-setup)
         ((ansible-mode) . flymake-mode)))

(use-package ansible-doc
  :hook (ansible-mode . ansible-doc-mode))

(require 'sudo-edit)
(require 'portage)

(use-package ctable :ensure nil :defer t
  :config
  (setq ctbl:default-rendering-param
        (make-ctbl:param
         :display-header      t
         :fixed-header        nil
         :bg-colors           nil
         :vline-colors        "DarkGray"
         :hline-colors        "DarkGray"
         :draw-vlines         'all
         :draw-hlines         '(1)
         :vertical-line       ?│
         :horizontal-line     ?─
         :left-top-corner     ?┌
         :right-top-corner    ?┐
         :left-bottom-corner  ?└
         :right-bottom-corner ?┘
         :top-junction        ?┬
         :bottom-junction     ?┴
         :left-junction       ?├
         :right-junction      ?┤
         :cross-junction      ?┼)))

(use-package portage-navi :ensure nil
  :custom
  (pona:package-equery-use-native-highlighting t)
  :bind (:map pona:package-detail-mode-map
              ("t" . portage-toggle-use-flag-at-point)))
(use-package portage
  :commands ( portage-depclean portage-deselect
              portage-emerge-mode
              portage-emerge-preserved-rebuild
              portage-emerge-pv portage-emerge-oneshot
              portage-sync portage-full-upgrade
              ;; With smart-live-rebuild:
              ;; portage-smart-live-rebuild
              portage-install portage-uninstall
              ;; With pona:
              ;; portage-package-details
              portage-refresh-cache
              portage-eselect-module-set portage-eselect-emacs-set
              eselect)
  :config (defalias 'eselect 'portage-trivial-eselect)
  :custom
  (portage-dedicated-use-flags-file-relative "package.use/99-adhoc")
  (portage-load-site-gentoo-d-changes-on-install t))

(use-package portage-emerge-mode
  :custom (portage-load-site-gentoo-d-changes-on-install t))

(use-package portage-toggle-use
  :commands (portage-toggle-useflag))

(use-package portage-elisp-set
  :commands (portage-update-elisp-set))



(setopt markdown-command "markdown2")


(use-package rfc-mode)
(use-package helm-info)

(use-package nov)

(setq 
     user-full-name "artsi0m"
     user-mail-address "karakin2000@gmail.com")

(use-package smtpmail
    :custom
    (smtpmail-smtp-server "smtp.gmail.com")
     (smtpmail-stream-type 'starttls )
     (smtpmail-smtp-service 587)
     (smtpmail-servers-requiring-authorization "*")
     (send-mail-function 'smtpmail-send-it)
     :ensure nil)

(use-package gnus
  :custom
  (gnus-save-score t)
  (gnus-startup-file "~/howm/.newsrc")
  (gnus-backup-startup-file 'never)
  (gnus-select-method '(nnnil nil))
  (nnrss-use-local t)
  (gnus-use-cache t)
  :init
  (add-to-list 'gnus-secondary-select-methods
	       '(nnimap "gmail"
			(nnimap-address "imap.gmail.com")
	      (nnmail-expiry-target "nnimap+gmail:[Gmail]/Корзина")
	      (nnimap-server-port 993)
	      (nnimap-stream ssl)
	      (nnir-search-engine imap)
	      (nnmail-expiry-wait immediate)))
  (add-to-list 'gnus-secondary-select-methods '(nntp "news.gwene.org"))
  (add-to-list 'gnus-secondary-select-methods '(nntp "news.gmane.io"))
  (add-to-list 'gnus-secondary-select-methods '(nntp "news.eternal-september.org"))
  (add-to-list 'gnus-secondary-select-methods
      '(nntp "feedbase"
             (nntp-open-connection-function nntp-open-tls-stream) ; feedbase does not do STARTTLS (yet?)
             (nntp-port-number 563) ; nntps
             (nntp-address "feedbase.org")))
  (delete-dups gnus-secondary-select-methods))
