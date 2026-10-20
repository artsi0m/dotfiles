;; coping with codepages on MS windows
;; This part should be loaded before reading org files
;; to make it possible to read 1/3
(defvar *fs-encoding* 'utf-8)
(prefer-coding-system 'utf-8-unix)

;; 2/4 variables set by custom
(load (setq custom-file (file-name-concat user-emacs-directory "custom.el")) 'noerror)


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


(use-package reverse-im
  ;; depends on
  ;; app-emacs/seq::gnu-elpa
  :ensure t
  :init (reverse-im-mode)
  :custom
  (reverse-im-input-methods '("cyrillic-colemak"))
  (reverse-im-cache-file "~/.cache/emacs/reverse-im-cache.el"))


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
  :init (modus-themes-load-random-light)
  :when (not (null window-system)))

(use-package consult :ensure t)

(use-package consult-eglot :commands (eglot) :ensure t)
(use-package dired
  :custom (dired-dwim-target t))

(use-package magit :commands (magit))

(use-package git-modes :ensure t)

(use-package howm
  :init (when (not (eq system-type 'windows-nt))
          (setq howm-view-use-grep t))
  (setq howm-prefix (kbd "C-c ;"))
  :custom
  ;; Avoid conflicts with Org-mode by changing Howm's prefix from "C-c ,".
  (howm-search-other-dir t))


(use-package howm-use-any-markup
  :vc (:url "https://github.com/artsi0m/howm-use-any-markup")
  :ensure t)

(defun my-org-agenda-file-names-in-howm ()
  "Return list of absoulute filenames of files with :agenda: tag in howm"
  (delete-dups
   (mapcar #'car (howm-grep "\:agenda\:"
			    (howm-files-in-directory howm-directory)))))

(define-advice org-agenda (:before (&rest _args))
  (setq org-agenda-files (my-org-agenda-file-names-in-howm)))

(define-advice org-clock-report (:before (&rest _args))
  (setq org-agenda-files (my-org-agenda-file-names-in-howm)))

(defconst my-howm-subsubdir-regexp
  (rx (seq "howm/" (= 4 num ) "/" (= 2 num)))
  "Regexp that matches second level of subdirectories in howm,
   like  ~/homw/2024/01/, but with ltximg")

(defconst my-howm-excluded-subdirs-regexp
  (rx (or ".git" "ltximg" "auto"))
  "Regexp that matches howm subdirs that I don't need
   like .git .elfeed and ltximg, basically like .gitignore,
   but i don't want to rely on them")

(defun my-howm-subsubdir-exclude (dir)
  (if (string-match-p my-howm-subsubdir-regexp dir)
      (unless
	  (string-match-p my-howm-excluded-subdirs-regexp dir) dir)
    nil))

(defun my-howm-subsubdirs ()
  (thread-last
    (directory-files-recursively
     howm-directory directory-files-no-dot-files-regexp t)
    (seq-filter #'file-directory-p)
    (seq-filter #'my-howm-subsubdir-exclude)))

(use-package org-fc
  :load-path "~/Projects/org-fc"
  :custom
  (org-fc-directories (my-howm-subsubdirs))
  (org-fc-review-history-file "~/howm/.org-fc-reviews.tsv")
  :config

  (defun org-fc-awk--find (paths)
    "Original org-fc-awk--find modified for use with .txt files"
    (format
     "find -L %s -type f -name \"*.txt\" -not -name \".*\"  -print0" ;;
     (mapconcat  (lambda (path)
		   (shell-quote-argument (expand-file-name path)))
                 paths " ")))

  (setq org-fc-default-algo 'fsrs6)
  (require 'org-fc-hydra)
  (require 'org-fc-algo-fsrs))

(use-package org-srs
  :custom org-srs-query-directory-file-regexp (rx (seq bos (not (any ".")) (*? anything) ".txt" eos)))

;; Use C locale for time. Needed for org-pomodoro on windows
(setq system-time-locale "C")

(use-package org-pomodoro
  ;;   depends on
  ;; app-emacs/alert::melpa
  ;; app-emacs/gntp::melpa
  ;; app-emacs/log4e::gentoo ~amd64
  :preface (defvar my-sound-complete
             "/usr/share/sounds/freedesktop/stereo/complete.oga")
  :custom
  (org-pomodoro-keep-killed-pomodoro-time 't)
  (org-pomodoro-length 80)
  (org-pomodoro-short-break-length 15)
  (org-pomodoro-long-break-length 35)
  (org-pomodoro-format "🍅~%s")
  (org-pomodoro-play-sounds t)
  (org-pomodoro-finished-sound-p t)
  (org-pomodoro-audio-player "ffplay -nodisp -autoexit -i")
  (org-pomodoro-finished-sound my-sound-complete)
  (org-pomodoro-short-break-sound my-sound-complete)
  (org-pomodoro-long-break-sound my-sound-complete))

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

(use-package pydoc);; app-emacs/pydoc::melpa
(use-package slime :commands (slime)) ;; app-emacs/slime::akater

(when (executable-find "sbcl")
  (setq inferior-lisp-program "sbcl"))


(use-package yaml-mode) ;; app-emacs/yaml-mode::gentoo

(use-package flymake-yamllint ;; app-emacs/flymake-yamllint::artsi0m
  :when (executable-find "yamllint")
  :hook (yaml-mode . flymake-yamllint-setup)) 

;; (use-package docker-compose-mode)

;; (use-package ansible
;;     :hook (ansible-mode . whitespace-mode)
;;     :ensure t)

;; (use-package flymake-ansible-lint
;;   :when (executable-find "ansible-lint")
;;   :ensure t
;;   :commands flymake-ansible-lint-setup
;;   :hook (((ansible-mode) . flymake-ansible-lint-setup)
;;          ((ansible-mode) . flymake-mode)))

;; (use-package ansible-doc
;;   :hook (ansible-mode . ansible-doc-mode))

(require 'cl-macs)
(require 'sudo-edit)
(require 'portage)
(require 'akater-conf)

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



(use-package helm-info)

(use-package nov)

(setq 
     user-full-name "Artsiom Karakin"
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
  (gnus-use-cache t)
  :init
  (setq nnrss-use-local t)
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

(use-package telega
  :custom
  (telega-debug 't)
  (telega-chat-send-message-on-ret "ignore")
  :bind ("C-<return>" . telega-chatbuf-input-send)
  :commands (telega)
  :config
  (telega-notifications-mode 1)
  (define-key global-map (kbd "C-c t") telega-prefix-map)
  :hook (telega-chat-mode . telega-completions-setup-capf)
  :defer 't)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (C . t)
   (shell . t)))


(use-package rmsbolt)
