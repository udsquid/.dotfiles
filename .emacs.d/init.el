;; -*- lexical-binding: t; -*-
;; programs may run faster with lexical-binding

;; set 'command' as META key, 'option/alt' as SUPER key
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;; switch 'C-x' & 'C-t' keys
(keyboard-translate ?\C-x ?\C-t)
(keyboard-translate ?\C-t ?\C-x)

;; setup package system
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-always-defer t)

;; clean up emacs directory
(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-etc-file-name "custom.el")))

;; better hacks on garbage collection
(use-package gcmh
  :demand t
  :init
  (gcmh-mode t))

;; setup theme
(use-package cyberpunk-theme
  :demand t
  :init
  (load-theme 'cyberpunk t))

;; turn off any window widgets
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; setup font
(set-face-attribute 'default nil
		    :font    "DejaVu Sans Mono"
		    :height  180)

;; cursor jumping package
(use-package avy
  :bind ("M-o" . avy-goto-char))

;; highlight current line
(global-hl-line-mode t)

;; show column number
(setq column-number-mode t)

;; better help system
(use-package helpful)

;; completion framework
(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t))

(use-package orderless
  :init
  (setq completion-category-defaults nil)
  :custom
  (completion-styles '(orderless))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package consult)

;; disable auto save buffer
(setq auto-save-default nil)
;; disable backup file
(setq make-backup-files nil)
;; disable lock file mechanism
(setq create-lockfiles nil)

;; turn off newbie protection
(put 'narrow-to-region 'disabled nil)

;; move around between windows
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; smart select region
(use-package expand-region
  :bind (("s-h" . er/expand-region)
	 ("s-i" . er/mark-inside-quotes)
	 ("s-o" . er/mark-outside-quotes)))

;; show hint for key bindings
(use-package which-key
  :demand t
  :config
  (which-key-mode))

;; highlight indentation levels
(use-package highlight-indent-guides
  :init
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-character-face-perc 20)
  (highlight-indent-guides-method 'bitmap))

;; show recent files and projects
(use-package dashboard
  :demand t
  :config
  (dashboard-setup-startup-hook))

;; edit multiple lines at once
(use-package multiple-cursors
  :bind (("s-t" . mc/mark-next-like-this)
	 ("s-r" . mc/mark-previous-like-this)))

;; pretty icons
;; remember to run command: all-the-icons-install-fonts
(use-package all-the-icons)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode)
  :config
  (setq all-the-icons-dired-monochrome nil))

;; fancy but minimal mode-line
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-env-version nil)
  (setq vc-display-status nil)
  (advice-add #'doom-modeline-update-vcs-text :override #'ignore)
  (setq doom-modeline-buffer-file-name-style 'truncate-with-project))

;; manage buffers in project perspective
(use-package perspective
  :init
  (persp-mode)
  :bind (("C-x b" . persp-switch-to-buffer*)
	 ("C-x k" . persp-kill-buffer*))
  :custom
  (persp-sort 'access)
  (persp-mode-prefix-key [8388720])
  (persp-state-default-file (concat user-emacs-directory ".persp")))

;; show the matches while in search/replace
(use-package anzu
  :init
  (global-anzu-mode)
  :bind (([remap query-replace] . 'anzu-query-replace)
	 ([remap query-replace-regexp] . 'anzu-query-replace-regexp)))

;; smart delete whitespaces & blank lines
(use-package ws-butler
  :init
  (ws-butler-global-mode))

;; smart way to manipulate parenthesis
(use-package smartparens
  :bind (("M-[" . sp-backward-sexp)
	 ("M-]" . sp-forward-sexp))
  :init
  (show-smartparens-global-mode t)
  (add-hook 'prog-mode-hook 'turn-on-smartparens-mode))

;; better git client
(use-package magit
  :defer t
  :config
  (setenv "LANG" "en_US"))

;; better note app
(defun org-setup-font ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
			  '(("^ *\\([-*]\\) "
			     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1        . 1.5)
                  (org-level-2        . 1.4)
                  (org-level-3        . 1.3)
                  (org-level-4        . 1.2)
                  (org-level-5        . 1.2)
                  (org-level-6        . 1.2)
                  (org-level-7        . 1.2)
                  (org-level-8        . 1.2)
		  (org-document-title . 2.0)))
    (set-face-attribute (car face) nil
			:family "Arial Rounded MT Bold"
			:weight 'regular
			:height (cdr face)))

  ;; set faces for markups & code blocks
  (set-face-attribute 'org-verbatim nil
		      :inherit '(shadow fixed-pitch)
		      :foreground "orchid2")
  (set-face-attribute 'org-code nil
		      :inherit '(shadow)
		      :foreground "light green")
  (set-face-attribute 'org-block nil
		      :background nil)
  (set-face-attribute 'bold nil
		      :height 1.05)
  )

(defun org-setup-mode ()
  (visual-line-mode t)
  (org-indent-mode)
  (auto-revert-mode t))

(defun org-setup-refile ()
  (setq org-refile-targets
	'((nil :maxlevel . 5)
	  ("Archive.org" :maxlevel . 1)
	  ("Queue.org" :level . 0)
	  ("Inbox.org" :level . 0)))
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm))

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files
	(append (find-lisp-find-files (concat org-directory "/GTD") "\.org$")
		(my/org-roam-list-notes-by-tag "Project"))))

(defun org-setup-agenda ()
  (require 'find-lisp)
  (require 'org-roam)
  ;; also want to see done tasks in 'Archive.org'
  (setq org-agenda-files
	(append (find-lisp-find-files (concat org-directory "/GTD") "\.org$")
		(my/org-roam-list-notes-by-tag "Project")))
  (setq org-agenda-custom-commands
	`(("g" "Agenda Overview"
	   ((agenda ""
		    ((org-deadline-warning-days 7)))
	    (todo "TODO|NEXT"
		  ((org-agenda-overriding-header "To Refile")
		   (org-agenda-files '(,(concat org-directory "GTD/Inbox.org")))))
	    (todo "DONE|CANCELLED"
		  ((org-agenda-overriding-header "To Archive")
		   (org-agenda-files '(,(concat org-directory "GTD/Inbox.org")
				       ,(concat org-directory "GTD/Queue.org")))))
	    (todo "NEXT"
		  ((org-agenda-overriding-header "In Progress")
		   (org-agenda-files '(,(concat org-directory "GTD/Queue.org")
				       ,(apply 'format "%s"
					       (my/org-roam-list-notes-by-tag "Project"))))))
	    (todo "TODO"
		  ((org-agenda-overriding-header "Projects")
		   (org-agenda-files (my/org-roam-list-notes-by-tag "Project"))))
	    (tags-todo "+{work\\|Work}+TODO=\"TODO\""
		  ((org-agenda-overriding-header "Work")))
	    (tags-todo "-{work\\|Work}+TODO=\"TODO\""
		  ((org-agenda-overriding-header "One-off Tasks")
		   (org-agenda-files '(,(concat org-directory "GTD/Queue.org")))))
	    ))))
  )

(defun org-setup-capture ()
  (server-start)
  (require 'org-protocol)

  (setq org-capture-templates
	`(("i" "Inbox"
	   entry (file ,(concat org-directory "GTD/Inbox.org"))
	   "* TODO %?")
	  ("c" "org-protocol-capture"
	   entry (file ,(concat org-directory "GTD/Inbox.org"))
	   "* TODO [[%:link][%:description]]\n\n%u" :immediate-finish t)
	  ("q" "org-protocol-capture (with quote)"
	   entry (file ,(concat org-directory "GTD/Inbox.org"))
	   "* TODO [[%:link][%:description]]\n\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n%u" :immediate-finish t)
	  ("j" "Journal"
	   entry (file+olp+datetree ,(concat org-directory "journal/Journal.org"))
	   "\n* %<%I:%M %p> %^{Heading}\n\n%?\n\n"
	   :empty-lines 1)
	  ))
  )

(use-package org
  :hook (org-mode . org-setup-mode)
  :config
  (setq org-confirm-babel-evaluate nil)
  (setq org-ellipsis " »")
  (setq org-hide-emphasis-markers t)
  (setq org-startup-folded nil)
  (setq org-log-into-drawer t)
  (setq org-startup-with-inline-images t)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-directory "~/Dropbox/mywiki/")
  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	  (sequence "|" "CANCELLED(c!)")))
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  (org-setup-font)
  (org-setup-refile)
  (org-setup-agenda)
  (org-setup-capture)

  ;; enable language execution
  (org-babel-do-load-languages 'org-babel-load-languages
			       '((emacs-lisp . t)
				 (python .t )
				 (shell . t)))

  ;; code block generator
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))

  :custom
  (org-image-actual-width nil))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun org-setup-visual ()
  (setq visual-fill-column-width 80)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . org-setup-visual))

(setq org-roam-v2-ack t)
(use-package org-roam
  :after org
  :custom
  (org-roam-directory "~/Dropbox/mywiki")
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "\n* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol)
  (setq org-roam-capture-ref-templates
	'(("r" "ref" plain
	   "%?"
	   :if-new (file+head "${slug}.org"
			      "#+title: ${title}\n#+date: %U\n")
	   :unnarrowed t)))
  )

(use-package org-download
  :after org
  :bind
  (:map org-mode-map
        (("s-Y" . org-download-screenshot)
         ("s-y" . org-download-yank)))
  :config
  (setq org-download-screenshot-method "screencapture -i %s")
  (setq-default org-download-image-dir "~/Dropbox/mywiki/images")
  (setq-default org-download-heading-lvl nil)
  )

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t))

(use-package deft
  :commands (deft)
  :custom
  (deft-directory org-roam-directory)
  (deft-recursive t)
  (deft-strip-summary-regexp ":PROPERTIES:\n\\(.+\n\\)+:END:\n"))

(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; better terminal
(use-package vterm
  :commands vterm
  :bind
  (:map vterm-mode-map
	("M-a" . vterm-beginning-of-line)
	("M-i" . vterm-beginning-of-line)
	("M-e" . move-end-of-line)
	("M-p" . vterm-previous-prompt)
	("M-n" . vterm-next-prompt)
	("M-v" . yank)
	("M-C" . vterm-copy-mode)
	("C-u" . vterm-send-C-u))
  (:map vterm-copy-mode-map
	("M-C" . vterm-copy-mode))
  :config
  (setq vterm-shell "/usr/local/bin/bash")
  (setq vterm-max-scrollback 10000)
  (unbind-key "M-w" vterm-mode-map)
  (unbind-key "M-p" vterm-mode-map)
  (unbind-key "M-n" vterm-mode-map))

;; copy environment variables
(use-package exec-path-from-shell
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; better redo
(use-package undo-fu
  :bind ("M-Z" . undo-fu-only-redo))

;; able to recognize remote fancy shell prompt
(setq tramp-shell-prompt-pattern
      "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>].* *\\(^[\\[[0-9;]*[a-zA-Z] *\\)*")

;; better dired experience
(setq delete-by-moving-to-trash t)

(if (eq system-type 'darwin)
    (setq trash-directory "~/.Trash"))

;; --- handy custom keys ---

;; ### cursor moving ###
(global-set-key (kbd "M-a") 'move-beginning-of-line)
(global-set-key (kbd "M-e") 'move-end-of-line)
(global-set-key (kbd "M-i") 'back-to-indentation)

(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-N") 'scroll-up-command)
(global-set-key (kbd "M-P") 'scroll-down-command)

;; ### buffer & window ###
(global-set-key (kbd "M-w") 'other-window)
(global-set-key (kbd "s-w") 'other-window)

(global-unset-key (kbd "C-x C-p"))
(global-set-key (kbd "C-x C-p C-f") 'project-find-file)

;; quick switch between two recent buffers
(fset 'quick-switch-buffer [?\C-x ?b return])
(global-set-key (kbd "s-f") 'quick-switch-buffer)

;; ### editing ###
(global-set-key (kbd "M-c") 'kill-ring-save)
(global-set-key (kbd "M-v") 'yank)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "M-y") 'yank-pop)

(global-set-key (kbd "M-k") 'kill-line)
(global-set-key (kbd "M-j") (lambda () (interactive) (join-line -1)))
(global-set-key (kbd "M-t") 'capitalize-word)

(global-set-key (kbd "M-z") 'undo)

(global-set-key (kbd "M-.") 'completion-at-point)

;; helper functions
(defun split-window-down-and-move-there-dammit ()
  (interactive)
  (split-window-below)
  (windmove-down))

(defun split-window-right-and-move-there-dammit ()
  (interactive)
  (split-window-right)
  (windmove-right))

(defun my/buffer-name ()
  (interactive)
  (let ((n (buffer-name)))
    (kill-new n)
    (message n)))

(defun my/buffer-path ()
  (interactive)
  (let ((n default-directory))
    (kill-new n)
    (message n)))

(defun my/buffer-full-name ()
  (interactive)
  (let ((n (buffer-file-name)))
    (kill-new n)
    (message n)))

(defun my/jump-to-mark ()
  (interactive)
  (let ((current-prefix-arg 4))
    (call-interactively #'set-mark-command)))

;; key-binding manager
(use-package general
  :config
  (general-auto-unbind-keys)
  (general-create-definer my/leader-keys
    :prefix "M-SPC")

  (my/leader-keys
    ;; perspective
    "p"  '(:ignore t              :which-key "persp")
    "pt" '(persp-switch           :which-key "switch/create")
    "pp" '(persp-switch-last      :which-key "back")
    "pf" '(persp-switch-to-buffer :which-key "buffer")
    "pl" '(persp-state-load       :which-key "load")
    "ps" '(persp-state-save       :which-key "save")
    "pk" '(persp-kill             :which-key "kill")
    "pm" '(persp-set-buffer       :which-key "move")
    "pr" '(persp-rename           :which-key "rename")

    ;; helpful
    "h"  '(:ignore t        :which-key "help")
    "hf" '(helpful-callable :which-key "function")
    "hv" '(helpful-variable :which-key "variable")
    "hk" '(helpful-key      :which-key "key")
    "hm" '(describe-mode    :which-key "mode")

    ;; file
    "f"  '(:ignore t                :which-key "file")
    "fo" '(find-file                :which-key "open")
    "fw" '(ns-open-file-using-panel :which-key "open via window")
    "fp" '(project-find-file        :which-key "project")

    ;; multiple-cursors
    "m"  '(:ignore t                       :which-key "mark")
    "me" '(mc/mark-more-like-this-extended :which-key "extended")
    "ml" '(mc/edit-lines                   :which-key "line")
    "mg" '(mc/mark-all-in-region           :which-key "region")
    "my" '(yank-rectangle                  :which-key "yank multiple")

    ;; org-mode
    "o"   '(:ignore t                       :which-key "org-mode")
    "oc"  '(org-capture                     :which-key "capture")
    "og"  '(org-agenda                      :which-key "agenda")
    "or"  '(org-refile                      :which-key "refile")
    "oa"  '(org-archive-subtree             :which-key "archive")
    "ob"  '(org-insert-structure-template   :which-key "block")
    "os"  '(org-sort                        :which-key "sort")
    "on"  '(org-add-note                    :which-key "note")
    "of"  '(my/org-roam-refresh-agenda-list :which-key "rebuild org-agenda-files")
    "ot"  '(org-set-tags-command            :which-key "set tags")
    "ol"  '(:ignore t                       :which-key "link")
    "olc" '(org-store-link                  :which-key "copy")
    "olv" '(org-insert-link                 :which-key "paste")
    "oo"  '(org-open-at-point               :which-key "open")
    "op"  '(org-set-property                :which-key "property")
    "oe"  '(:ignore t                       :which-key "entity")
    "oep" '(org-toggle-pretty-entities      :which-key "pretty")
    "oeh" '(org-entities-help               :which-key "help")
    "oi"  '(org-time-stamp-inactive         :which-key "inactive timestamp")

    ;; org-roam
    "r"   '(:ignore t                      :which-key "org-roam")
    "rf"  '(org-roam-node-find             :which-key "find file")
    "ri"  '(org-roam-node-insert           :which-key "insert")
    "rb"  '(org-roam-buffer-toggle         :which-key "org-roam buffer")
    "ra"  '(:ignore t                      :which-key "alias")
    "raa" '(org-roam-alias-add             :which-key "add")
    "rar" '(org-roam-alias-remove          :which-key "remove")
    "rr"  '(org-roam-refile                :which-key "refile")
    "re"  '(:ignore t                      :which-key "reference")
    "rea" '(org-roam-ref-add               :which-key "add")
    "rt"  '(:ignore t                      :which-key "tag")
    "rta" '(org-roam-tag-add               :which-key "add")
    "rtd" '(org-roam-tag-remove            :which-key "remove")

    ;; org-roam-dailies
    "d"   '(:ignore t                          :which-key "dailies")
    "dc"  '(:ignore t                          :which-key "capture")
    "dcc" '(org-roam-dailies-capture-date      :which-key "certain day")
    "dct" '(org-roam-dailies-capture-today     :which-key "today")
    "dcy" '(org-roam-dailies-capture-yesterday :which-key "yesterday")
    "dg"  '(:ignore t                          :which-key "goto")
    "dgg" '(org-roam-dailies-goto-date         :which-key "certain day")
    "dgt" '(org-roam-dailies-goto-today        :which-key "today")
    "dgy" '(org-roam-dailies-goto-yesterday    :which-key "yesterday")

    ;; buffer
    "b"  '(:ignore t               :which-key "buffer")
    "bb" '(persp-switch-to-buffer* :which-key "switch")
    "bk" '(persp-kill-buffer*      :which-key "kill")
    "bn" '(my/buffer-name          :which-key "name")
    "bp" '(my/buffer-path          :which-key "path")
    "bf" '(my/buffer-full-name     :which-key "full name")

    ;; window
    "w"  '(:ignore t                                :which-key "window")
    "wr" '(split-window-right-and-move-there-dammit :which-key "right")
    "wd" '(split-window-down-and-move-there-dammit  :which-key "down")
    "wo" '(delete-other-windows                     :which-key "only")
    "ww" '(delete-window                            :which-key "close")

    ;; consult
    "c"  '(:ignore t                   :which-key "consult")
    "cl" '(consult-line                :which-key "line")
    "cg" '(consult-ripgrep             :which-key "ripgrep")
    "ch" '(consult-org-heading         :which-key "heading")
    "ci" '(consult-imenu               :which-key "imenu")
    "cm" '(consult-mark                :which-key "mark")
    "ck" '(consult-yank-from-kill-ring :which-key "kill ring")
    )
  )

(defun my/ins-4-spaces ()
  (dotimes (_ 4) (insert " ")))

(defun my/del-4-spaces ()
  (dotimes (_ 4) (delete-backward-char 1)))

(use-package hydra
  :config
  (defhydra hydra-text-scale (:timeout 4)
    "scale text"
    ("l" text-scale-increase   "large")
    ("s" text-scale-decrease   "small")
    ("r" (text-scale-adjust 0) "reset")
    ("q" nil                   "finish" :exit t))
  (defhydra hydra-multiple-cursors (:timeout 4)
    "mark"
    ("n" mc/mark-next-like-this      "next")
    ("p" mc/mark-previous-like-this  "prev")
    ("w" mc/mark-next-like-this-word "word")
    ("a" mc/mark-all-like-this       "all")
    ("q" nil                         "finish" :exit t))
  (defhydra hydra-org-heading ()
    "heading"
    ("n" org-next-visible-heading        "next")
    ("p" org-previous-visible-heading    "prev")
    ("f" org-forward-heading-same-level  "forward")
    ("b" org-backward-heading-same-level "backward")
    ("u" (org-up-heading-safe)           "up")
    ("q" nil                             "finish" :exit t))
  (defhydra hydra-org-roam-day-traversal (:timeout 4)
    "day"
    ("n" org-roam-dailies-goto-next-note     "next")
    ("p" org-roam-dailies-goto-previous-note "prev")
    ("q" nil                                 "finish" :exit t))
  (defhydra hydra-indent (:timeout 4)
    "indent"
    ("s" (my/ins-4-spaces) "add 4 spaces")
    ("k" (my/del-4-spaces) "del 4 spaces")
    ("q" nil               "finish" :exit t))
  )

(my/leader-keys
  "t"  '(hydra-text-scale/body             :which-key "text")
  "mt" '(hydra-multiple-cursors/body       :which-key "this")
  "oh" '(hydra-org-heading/body            :which-key "org heading")
  "dt" '(hydra-org-roam-day-traversal/body :which-key "day traversal")
  "i"  '(hydra-indent/body                 :which-key "indentation")
  )
