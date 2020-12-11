;;        ___                                              __      
;;       /\_ \                                            /\ \__   
;; __  __\//\ \      __     ____    __  __    ___     __  \ \ ,_\  
;;/\ \/\ \ \ \ \   /'__`\  /\_ ,`\ /\ \/\ \  /'___\ /'__`\ \ \ \/  
;;\ \ \_/ | \_\ \_/\ \L\.\_\/_/  /_\ \ \_\ \/\ \__//\ \L\.\_\ \ \_ 
;; \ \___/  /\____\ \__/.\_\ /\____\\/`____ \ \____\ \__/.\_\\ \__\
;;  \/__/   \/____/\/__/\/_/ \/____/ `/___/> \/____/\/__/\/_/ \/__/
;;                                      /\___/                     
;;                                      \/__/                      

(require 'package)
(package-initialize) ;; You might already have this line
(setq package-enable-at-startup nil)

; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
; (add-to-list 'package-archives
;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)
; (add-to-list 'package-archives
;               '("org" . "http://orgmode.org/elpa/") t)
; (package-initialize)

;; CN package setting
(setq package-archives '(("gnu" . "http://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "http://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "http://mirrors.ustc.edu.cn/elpa/org/")))

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; macOS env settings
(when (memq window-system '(mac ns))
  ;; Set the environment to the same as the shell
  (use-package exec-path-from-shell
    :ensure t
    :config
    (exec-path-from-shell-initialize))

  ;; Set option key to be meta key
  (setq mac-control-modifier 'control)
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super)

  ;; Always use Default Browser when opening links
  (setq browse-url-browser-function 'browse-url-default-macosx-browser))

;; Max image size when using the builtin viewer
(setq max-image-size 50.0)

;; Disable visual bell
(setq visible-bell nil)

;; Disable backup files
(setq make-backup-files nil)
;; Disable auto save files
(setq auto-save-default nil)

;; UI settings
(when window-system
  ;; Disable pscroll bars in gui emacs
  (scroll-bar-mode -1)
  ;; Disable the tool bar in gui emacs
  (tool-bar-mode -1))

;; Change the scratch buffer message to nothing
(setq initial-scratch-message nil)

;; Don't suspend emacs with C-z
(global-unset-key [?\C-z])

;; Use iBuffer by default for C-x C-b which is more readable than default
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Shortcut for occur
(global-set-key (kbd "C-x C-o") 'occur)

;; Shortcut for rgrep using ripgrep because it's faster
(global-set-key (kbd "C-x C-r") 'ripgrep-regexp)

;; Shortcut for rectangle edits
(global-set-key (kbd "C-x r i") 'string-insert-rectangle)

;; Copy file name to clipboard
(defun copy-file-name ()
  "Put the current file name on the clipboard"
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      (file-name-directory default-directory)
                    (buffer-file-name))))
    (when filename
      (x-select-text filename))))

;; Screenshot as SVG using cairo (if emacs was built with --with-cairo)
(defun screenshot-svg ()
  "Save a screenshot of the current frame as an SVG image.
Saves to a temp file and puts the filename in the kill ring."
  (interactive)
  (let* ((filename (make-temp-file "Emacs" nil ".svg"))
         (data (x-export-frames nil 'svg)))
    (with-temp-file filename
      (insert data))
    (kill-new filename)
    (message filename)))


(use-package rust-mode)
;; LSP settings
;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
(setq lsp-keymap-prefix "s-l")

(use-package lsp-mode
    :hook ((rust-mode . lsp-deferred)
            ;; if you want which-key integration
            (lsp-mode . lsp-enable-which-key-integration))
    :commands lsp lsp-deferred)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
(use-package helm-lsp :commands helm-lsp-workspace-symbol)


;; UI settings
;; Nice startup screen
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Happy hacking Kun")
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (agenda . 5)))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq show-week-agenda-p t))

;; Emdash
(defun insert-em-dash ()
  "Insert a em-dash"
  (interactive)
  (insert "—"))
(global-set-key [(meta _)] 'insert-em-dash)

;; Delete trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Show the time
(display-time-mode 1)

;; Git using magit
(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-c g") 'magit-status)
  ;; Disable built in VC mode for better performance
  (setq vc-handled-backends nil)
  ;; Disable refreshing status for better performance
  (setq magit-refresh-status-buffer nil)
  ;; Always open the commit edit message in a new window instead of the
  ;; *magit* window so you can see the diff
  (add-to-list 'display-buffer-alist
	       '(".*COMMIT_EDITMSG". ((display-buffer-pop-up-window) .
				      ((inhibit-same-window . t))))))

;; Flycheck
(use-package flycheck
  :ensure t
  :config
  ;; (global-flycheck-mode)
  (setq flycheck-global-modes '(not rust-mode))
  (global-set-key (kbd "C-c M-n") 'flycheck-next-error)
  (global-set-key (kbd "C-c M-p") 'flycheck-previous-error))

;; Web mode
(use-package web-mode 
  :ensure t
  :config
  (defun web-mode-customization ()
    "Customization for web-mode."
    (setq web-mode-js-indent-offset 2)
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 2)
    (setq web-mode-code-indent-offset 2)
    (setq web-mode-enable-auto-pairing t)
    (setq web-mode-enable-css-colorization t))
  (add-hook 'web-mode-hook 'web-mode-customization)
  ;; Javascript
  (add-to-list 'auto-mode-alist '("\\.js$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
  ;; Turn off auto saving because js build tools hate temp files
  (add-hook 'web-mode-hook '(lambda () (setq auto-save-default nil)))
  ;; HTML
  (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
  ;; CSS
  (add-to-list 'auto-mode-alist '("\\.css$" . web-mode)))

(use-package typescript-mode 
  :ensure t
  :config
  (setq typescript-indent-level 2)
  (add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))
  (add-hook 'typescript-mode-hook #'eglot-ensure))

(use-package toml-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.toml$" . toml-mode)))

(use-package rust-mode
  :ensure t
  :config
  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (add-hook 'rust-mode-hook #'eglot-ensure))

(use-package eglot
  :ensure t
  :config
  (global-set-key (kbd "M-n") 'flymake-goto-next-error)
  (global-set-key (kbd "M-p") 'flymake-goto-prev-error)
  (define-key eglot-mode-map (kbd "C-c h") 'eglot-help-at-point)

  ;; Better support for rust projects with multiple sub projects
  (defun my-project-try-cargo-toml (dir)
    (when-let* ((output
                 (let ((default-directory dir))
                   (shell-command-to-string "cargo metadata --no-deps --format-version 1")))
                (js (ignore-errors (json-read-from-string output)))
                (found (cdr (assq 'workspace_root js))))
      (cons 'eglot-project found)))

  (cl-defmethod project-roots ((project (head eglot-project)))
    (list (cdr project)))

  (add-hook 'project-find-functions 'my-project-try-cargo-toml nil nil)

  (add-to-list 'eglot-server-programs
               '((typescript-mode) "typescript-language-server" "--stdio")))

;; YASnippet
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; Elisp
(use-package paredit
  :ensure t
  :config
  (add-hook 'elisp-mode-hook 'paredit-mode)
  (add-hook 'clojure-mode-hook 'paredit-mode))

;; Python
(use-package python-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode)))

(use-package elpy
  :ensure t
  :config
  (elpy-enable)
  (setq elpy-rpc-backend "rope"))

;; Ruby
(use-package robe
  :ensure t
  :config
  ;; Sane indenting
  (setq ruby-deep-indent-paren nil)
  ;; Don't auto add file encodings!!!
  (setq ruby-insert-encoding-magic-comment nil)
  (add-hook 'ruby-mode-hook 'robe-mode)
  ;; Use specific rubocop
  (defun use-custom-rubocop ()
    (let* ((root (locate-dominating-file
		  (or (buffer-file-name) default-directory)
		  "scripts/bin/rubocop"))
	   (rubocop (and root
			 (expand-file-name "scripts/bin/rubocop"
					   root))))
      (when (and rubocop (file-executable-p rubocop))
	(setq-local flycheck-ruby-rubocop-executable rubocop))))
  (add-hook 'flycheck-mode-hook #'use-custom-rubocop))

;; Format line numbers nicely
(setq linum-format (quote " %3d "))

;; Sass-mode
(use-package sass-mode
  :ensure t
  :config (setq sass-tab-width 2))

;; Processing mode
(use-package processing-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))
  (setq processing-location "~/Library/Processing"))

;; Markdown
(use-package markdown-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode)))

;; Nice writing layout
(use-package writeroom-mode
  :ensure t
  :config
  (add-hook 'writeroom-mode-hook
            (lambda ()
              ;; Use custom font face for this buffer only
              (defface tmp-buffer-local-face
                '((t :family "ETBembo" :height 180))
                "Temporary buffer-local face")
              (buffer-face-set 'tmp-buffer-local-face)
              ;; Add padding to the top of the frame
              (setq header-line-format " ")
              ;; Use a skinny cursor
              (make-local-variable 'cursor-type)
              (setq cursor-type 'bar))))

;; Detect things like weasel words
(use-package writegood-mode
  :ensure t
  :config
  (global-set-key "\C-c\C-gl" 'writegood-grade-level)
  (global-set-key "\C-c\C-ge" 'writegood-reading-ease))

;; Unity
(use-package glsl-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.shader$" . glsl-mode)))

;; Linum mode shortcut
(global-set-key (kbd "C-x l") 'linum-mode)

;; iEdit mode
(global-set-key (kbd "C-x ;") 'iedit-mode)

;; Web browser (eww)
(global-set-key (kbd "C-x M-w") 'eww)

;; Disable auto fill mode because it's annoying
(auto-fill-mode -1)
(remove-hook 'text-mode-hook #'turn-on-auto-fill)

;; Auto-complete company-mode
(use-package company
  :ensure t
  :config
  (add-hook 'after-init-hook 'global-company-mode))

;; Shortcuts for going forward and backwards cycling windows
(global-set-key (kbd "C-x p") 'other-window)
(global-set-key (kbd "C-x o") 'previous-multiframe-window)

;; Expand region
(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "\C-x\ =") 'er/expand-region))

;; Ace jump mode
(use-package ace-jump-mode
  :ensure t
  :config
  (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

;; Auto refresh all buffers when files change ie git branch switching
(global-auto-revert-mode t)

;; Don't use any character as the vertical border divider
(set-display-table-slot standard-display-table
                        'vertical-border
                        (make-glyph-code ? ))

;; Gui emacs still sets a line color in between
(set-face-background 'vertical-border "gray32")
(set-face-foreground 'vertical-border (face-background 'vertical-border))

;; When at the end of a buffer don't jump, scroll
(setq scroll-step 1 scroll-conservatively 10000)
(setq scroll-margin 0)

;; clojure
(use-package clojure-mode :ensure t)

;; Kibit for Clojure
;; A convenient command to run "lein kibit" in the project to which
;; the current emacs buffer belongs to.
(defun kibit ()
  "Run kibit on the current project.
   Display the results in a hyperlinked *compilation* buffer."
  (interactive)
  (compile "lein kibit"))

;; Rainbow parantheses
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Cider settings
(use-package cider
  :ensure t
  :config
  (add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'cider-repl-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook
	    '(lambda ()
	       (set-variable 'nrepl-server-command
			     "lein with-profile dev repl")))
  ;; Disable popup stacktraces except in repl
  (setq nrepl-popup-stacktraces nil)
  (setq nrepl-popup-stacktraces-in-repl t)

  ;; Disable auto-selection of the error buffer when it's displayed:
  (setq cider-auto-select-error-buffer nil)

  ;; Instructions for M-x cider-jack-in-clojurescript
  (setq cider-cljs-lein-repl
        "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))"))

;; Flyspell mode
(use-package flyspell
  :config
  (setq ispell-program-name "/usr/local/bin/aspell")
  (add-hook 'python-mode-hook (lambda () (flyspell-prog-mode)))
  (add-hook 'coffee-mode-hook (lambda () (flyspell-prog-mode)))
  (add-hook 'hbs-mode-hook (lambda () (flyspell-prog-mode)))
  (add-hook 'org-mode-hook (lambda () (flyspell-prog-mode))))

;; Use spaces instead of tabs when indenting
(setq-default indent-tabs-mode nil)

;; Org-mode

;; Copied from https://github.com/glasserc/etc/commit/3af96f2c780a35d35bdf1b9ac19d80fe2e6ebbf8
;; Work around built-in org-mode so we can load from ELPA.
;; First, remove the built-in org directory from the load-path.
;; Thanks to
;; http://stackoverflow.com/questions/20603578/emacs-does-not-see-new-installation-of-org-mode/20616703#20616703.
;; Without this, use-package will try to require org and succeed.
(eval-when-compile
  (require 'cl))

(setq load-path (remove-if (lambda (x) (string-match-p "org$" x)) load-path))
;; Second, trick emacs into forgetting about the fact that org is
;; a "built-in" package by removing it from package--builtins.
;; Without this, package will refuse to install org, since it's
;; "already installed".
;; package--builtins is only initialized when a query needs it.
(package-built-in-p 'org)   ;; prime package--builtins
(setq package--builtins (assq-delete-all 'org package--builtins))

(use-package org
  :ensure org-plus-contrib
  :pin org
  :config
  (setq org-directory "~/org")

  ;; When opening a file make sure everything is expanded
  (setq org-startup-folded nil)

  ;; Always wrap lines
  (setq org-startup-truncated nil)

  ;; Hide markers like /emphasis/
  (setq org-hide-emphasis-markers t)

  ;; Show inline images
  (org-display-inline-images t t)

  ;; Don't show full size images otherwise it's too large when
  ;; displaying inline
  (setq org-image-actual-width nil)

  ;; Prettify outlines
  (add-hook 'org-mode-hook
            (lambda ()
              (push '("- [ ]"     . "☐") prettify-symbols-alist)
              (push '("- [X]"     . "☑") prettify-symbols-alist)
              (prettify-symbols-mode)))

  ;; Refile to the root of a file
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-targets '((org-agenda-files :level . 1)))

  ;; Show the agenda helper and viewer in split screen
  (defadvice org-agenda (around split-vertically activate)
    (let ((split-width-threshold 80))
      ad-do-it))

  (defadvice org-agenda-list (around split-vertically activate)
    (let ((split-width-threshold 80))
      ad-do-it))

  (defun org-agenda-and-todos ()
    (interactive)
    (org-agenda nil "n"))

  (defun org-agenda-and-todos-two-weeks ()
    (interactive)
    (let ((current-prefix-arg 14))
      (call-interactively 'org-agenda-and-todos)))

  (defun org-agenda-and-todos-last-week ()
    (interactive)
    (let ((current-prefix-arg -7))
      (call-interactively 'org-agenda-and-todos)))

  ;; Shortcut copy an internal link
  (global-set-key (kbd "C-c o l") 'org-store-link)

  ;; Shortcut to show preferred agenda view
  (global-set-key (kbd "C-c A") 'org-agenda-and-todos-two-weeks)

  ;; Show hours:minutes instead of days:hours
  (setq org-time-clocksum-format (quote (:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t)))

  ;; Shortcut to jump to last running clock
  (global-set-key (kbd "C-c C-x C-j") 'org-clock-jump-to-current-clock)

  ;; On startup show the agenda for the next 2 calendar weeks and all
  ;; todo items
  (add-hook 'after-init-hook 'org-agenda-and-todos-two-weeks)

  ;; Show org timestamps in 12h time
  (setq org-agenda-timegrid-use-ampm 1)

  ;; Always show the current day in org agenda
  (setq org-agenda-time-grid (quote
                              ((daily today today)
                               (800 1000 1200 1400 1600 1800 2000)
                               "......" "----------------")))

  ;; Color code the agenda based on type
  ;; http://dept.stat.lsa.umich.edu/~jerrick/org_agenda_calendar.html
  (defun color-org-header (tag col)
    (interactive)
    (goto-char (point-min))
    (while (re-search-forward tag nil t)
      (add-text-properties (match-beginning 0) (point-at-eol)
			   `(face (:foreground ,col)))))

  (add-hook 'org-finalize-agenda-hook
	    (lambda ()
	      (save-excursion
		(color-org-header "notes:"  "#66D9EF")
		(color-org-header "refile:" "#F92672"))))

  ;; Use longtable as the default table style when exporting
  (setq org-latex-default-table-environment "longtable")

  ;; Don't position tables in the center
  (setq org-latex-tables-centered nil)

  ;; Fix some org-mode + yasnippet conflicts
  ;; http://stackoverflow.com/questions/9418148/conflicts-between-org-mode-and-yasnippet
  (defun yas/org-very-safe-expand ()
    (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

  (add-hook 'org-mode-hook
	    (lambda ()
	      (make-variable-buffer-local 'yas/trigger-key)
	      (setq yas/trigger-key [tab])
	      (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
	      (define-key yas/keymap [tab] 'yas/next-field)))

  (add-hook 'org-mode-hook (lambda ()
                             (make-variable-buffer-local 'visual-line-mode)
                             (visual-line-mode)))

  ;; Show syntax highlighting per language native mode in *.org
  (setq org-src-fontify-natively t)
  ;; For languages with significant whitespace like Python:
  (setq org-src-preserve-indentation t)

  ;; Timestamp new todos
  (setq org-log-done 'time)
  (setq org-startup-indented t)

  ;; Agenda
  (setq org-agenda-text-search-extra-files
	'(agenda-archives
	  "~/org/notes.org_archive"))
  (define-key global-map (kbd "C-c a") 'org-agenda)
  (define-key global-map (kbd "C-c C-a") 'org-agenda)

  ;; In org agenda log view also show recurring tasks
  (setq org-agenda-log-mode-items '(closed clock state))

  (defun org-archive-done-tasks ()
    "Archive all DONE and WONT-DO tasks."
    (interactive)
    (org-map-entries
     (lambda ()
       (org-archive-subtree)
       (setq org-map-continue-from (outline-previous-heading)))
     "+TODO=\"DONE\"" 'tree)
    (org-map-entries
     (lambda ()
       (org-archive-subtree)
       (setq org-map-continue-from (outline-previous-heading)))
     "+TODO=\"WONT-DO\"" 'tree))

  ;; Capture
  (global-set-key (kbd "C-c c") 'org-capture)
  (setq org-default-notes-file "~/org/refile.org")
  ;; Allow the creation of parent headings when refiling
  (setq org-refile-allow-creating-parent-nodes t)
  (setq org-capture-templates
	(quote (("t" "To Do" entry (file "~/org/refile.org")
		 "* TODO %?\n%U" :clock-in t :clock-resume t)
		("n" "Note" entry (file "~/org/refile.org")
		 "* %? %T :note:\n%U\n%a\n" :clock-in t :clock-resume t)
		("m" "Meeting" entry (file "~/org/refile.org")
		 "* Meeting w/%? %T :meeting:\n%U" :clock-in t :clock-resume t)
		("i" "Interview" entry (file "~/org/refile.org")
		 "* Interview w/%? %T :interview:\n%U" :clock-in t :clock-resume t))))

  ;; Auto mark parent todos as done if childrend are done
  (defun org-summary-todo (n-done n-not-done)
    "Switch entry to DONE when all subentries are done, to TODO otherwise."
    (let (org-log-done org-log-states)   ; turn off logging
      (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

  ;; Refile

	; Targets include this file and any file contributing to the agenda -
  ; up to 9 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
				   (org-agenda-files :maxlevel . 9))))

	; Use full outline paths for refile targets - we file directly with
  ; IDO
  (setq org-refile-use-outline-path t)

  ; Targets complete directly with IDO
  (setq org-outline-path-complete-in-steps nil)

  ; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

  ; Use IDO for both buffer and file completion and ido-everywhere to t
  (setq org-completion-use-ido t)
  ; Use the current window for indirect buffer display
  (setq org-indirect-buffer-display 'current-window)

;;;; Refile settings
  (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

  ;; Time format for clock table durations as h:mm
  (setq org-duration-format (quote h:mm))

  ;; Don't prompt for confirmation when exporting babel blocks
  (setq org-confirm-babel-evaluate nil))

;; Babel setup
(use-package ob-python
  :defer t
  :commands (org-babel-execute:python)
  :config
  (setq org-babel-python-command "python3"))

(use-package ob-shell
  :defer t
  :commands
  (org-babel-execute:sh
   org-babel-expand-body:sh

   org-babel-execute:bash
   org-babel-expand-body:bash))

(use-package htmlize 
  :ensure t)

;; Org export
(use-package ox-reveal 
  :ensure t)
(use-package ox-jira 
  :ensure t)
(use-package ox-hugo 
  :ensure t 
  :after ox)

;; Heavily modified based on https://github.com/novoid/title-capitalization.el/blob/master/title-capitalization.el
(defun title-capitalization (str)
  "Convert str to title case"
  (interactive)
  (with-temp-buffer
    (insert str)
    (let* ((beg (point-min))
           (end (point-max))
	   ;; Basic list of words which don't get capitalized according to simplified rules
	   ;; http://karl-voit.at/2015/05/25/elisp-title-capitalization/
           (do-not-capitalize-basic-words '("a" "ago" "an" "and" "as" "at" "but" "by" "for"
                                            "from" "in" "into" "it" "next" "nor" "of" "off"
                                            "on" "onto" "or" "over" "past" "so" "the" "till"
                                            "to" "up" "yet"
                                            "n" "t" "es" "s"))
	   ;; If user has defined 'my-do-not-capitalize-words, append to basic list
           (do-not-capitalize-words (if (boundp 'my-do-not-capitalize-words)
                                        (append do-not-capitalize-basic-words my-do-not-capitalize-words )
                                      do-not-capitalize-basic-words)))
      ;; Go to begin of first word
      (goto-char beg)
      (setq continue t)

      ;; Go through the region, word by word
      (while continue
        (let ((last-point (point)))
          (let ((word (thing-at-point 'word)))
            (if (stringp word)
                ;; Capitalize current word except when it is list member
                (if (and (member (downcase word) do-not-capitalize-words)
                         ;; Always capitalize first word
                         (not (= (point) 1)))
                    (downcase-word 1)

                  ;; If it's an acronym, don't capitalize
                  (if (string= word (upcase word))
                      (progn
                        (goto-char (+ (point) (length word) 1)))
                    (capitalize-word 1)))))

          (skip-syntax-forward "^w" end)

          ;; Break if we are at the end of the buffer
          (when (= (point) last-point)
            (setq continue nil))))

      ;; Always capitalize the last word
      (backward-word 1)

      (let ((word (thing-at-point 'word)))
        (if (and (>= (point) 0)
                 (not (member (or word "s")
                              '("n" "t" "es" "s")))
                 (not (string= word (upcase word))))
            (capitalize-word 1))))

    (buffer-string)))

;; Org roam
;; These are specified so they can be dynamically configured
;; by calling emacs in batch mode in a CI context
(setq org-roam-notes-path "~/org/notes")
(setq org-roam-publish-path "~/org/notes_roam")

(use-package org-roam
  :ensure t
  :hook
  ((after-init . org-roam-mode)
   ;; Need to add advice after-init otherwise they won't take
   (after-init . (lambda ()
                   (advice-add 'org-roam-capture
                               :after
                               'my/note-taking-init)

                   (advice-add 'org-roam-dailies-today
                               :after
                               'my/note-taking-init)

                   (advice-add 'org-roam-find-file
                               :after
                               'my/note-taking-init))))
  :custom
  (org-roam-directory org-roam-notes-path)
  :init
  ;; These functions need to be in :init otherwise they will not be
  ;; callable in an emacs --batch context which for some reason
  ;; can't be found in autoloads if it's under :config
  (defun my/org-roam--extract-note-body (file)
    (with-temp-buffer
      (insert-file-contents file)
      (org-mode)
      (first (org-element-map (org-element-parse-buffer) 'paragraph
               (lambda (paragraph)
                 (let ((begin (plist-get (first (cdr paragraph)) :begin))
                       (end (plist-get (first (cdr paragraph)) :end)))
                   (buffer-substring begin end)))))))

  ;; Include backlinks in org exported notes not tagged as private or
  ;; draft
  (defun my/org-roam--backlinks-list (file)
    (if (org-roam--org-roam-file-p file)
        (--reduce-from
         (concat acc (format "- [[file:%s][%s]]\n#+begin_quote\n%s\n#+end_quote\n"
                             (file-relative-name (car it) org-roam-directory)
                             (title-capitalization (org-roam-db--get-title (car it)))
                             (my/org-roam--extract-note-body (car it))))
         ""
         (org-roam-db-query
          [:select :distinct [links:source]
                   :from links
                   :left :outer :join tags :on (= links:source tags:file)
                   :where (and (= dest $s1)
                               (or (is tags:tags nil)
                                   (and
                                    (not-like tags:tags '%private%)
                                    (not-like tags:tags '%draft%))))]
          file))
      ""))

  (defun file-path-to-md-file-name (path)
    (let ((file-name (first (last (split-string path "/")))))
      (concat (first (split-string file-name "\\.")) ".md")))

  (defun file-path-to-slug (path)
    (let* ((file-name (car (last (split-string path "--"))))
           (title (first (split-string file-name "\\."))))
      (replace-regexp-in-string (regexp-quote "_") "-" title nil 'literal)))

  ;; Fetches all org-roam files and exports to hugo markdown
  ;; files. Adds in necessary hugo properties
  ;; e.g. HUGO_BASE_DIR. Ignores notes tagged as private or draft
  (defun org-roam-to-hugo-md ()
    (interactive)
    ;; Make sure the author is set
    (setq user-full-name "Alex Kehayias")

    (let ((files (mapcan
                  (lambda (x) x)
                  (org-roam-db-query
                   [:select [files:file]
                            :from files
                            :left :outer :join tags :on (= files:file tags:file)
                            :where (or (is tags:tags nil)
                                       (and
                                        (not-like tags:tags '%private%)
                                        (not-like tags:tags '%draft%)))]))))
      (mapc
       (lambda (f)
         ;; Use temporary buffer to prevent a buffer being opened for
         ;; each note file.
         (with-temp-buffer
           (message "Working on: %s" f)
           (insert-file-contents f)

           (goto-char (point-min))
           ;; Add in hugo tags for export. This lets you write the
           ;; notes without littering HUGO_* tags everywhere
           ;; HACK:
           ;; org-export-output-file-name doesn't play nicely with
           ;; temp buffers since it attempts to get the file name from
           ;; the buffer. Instead we explicitely add the name of the
           ;; exported .md file otherwise you would get prompted for
           ;; the output file name on every note.
           (insert
            (format "#+HUGO_BASE_DIR: %s\n#+HUGO_SECTION: ./\n#+HUGO_SLUG: %s\n#+EXPORT_FILE_NAME: %s\n"
                    org-roam-publish-path
                    (file-path-to-slug f)
                    (file-path-to-md-file-name f)))

           ;; If this is a placeholder note (no content in the
           ;; body) then add default text. This makes it look ok when
           ;; showing note previews in the index and avoids a headline
           ;; followed by a headline in the note detail page.
           (if (eq (my/org-roam--extract-note-body f) nil)
               (progn
                 (goto-char (point-max))
                 (insert "\n/This note does not have a description yet./\n")))

           ;; Add in backlinks because
           ;; org-export-before-processing-hook won't be useful the
           ;; way we are using a temp buffer
           (let ((links (my/org-roam--backlinks-list f)))
             (unless (string= links "")
               (goto-char (point-max))
               (insert (concat "\n* Links to this note\n") links)))

           (org-hugo-export-to-md)))
       files)))
  :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph)
               ("C-c n c" . org-roam-capture)
               ("C-c n j" . org-roam-dailies-today)
               ("C-c n r" . org-roam-random-note)
               ("C-c n u" . org-roam-unlinked-references)
               ("C-c n e" . org-roam-to-hugo-md)
               ;; Full text search notes with an action to insert
               ;; org-mode link
               ("C-c n s" . helm-rg))
              :map org-mode-map
              (("C-c n i" . org-roam-insert)
               ("C-c n I" . org-roam-insert-immediate))))

  :config
  (setq org-roam-capture-templates
	(quote (("d" "Default" plain (function org-roam--capture-get-point)
                 "%?"
                 :file-name "%(format-time-string \"%Y-%m-%d--%H-%M-%SZ--${slug}\" (current-time) t)"
                 :head "#+TITLE: ${title}\n#+DATE: %<%Y-%m-%d>\n#+ROAM_ALIAS:\n#+ROAM_TAGS:\n\n"
                 :unnarrowed t))))

  (setq org-roam-dailies-capture-templates
	(quote (("d" "Default" plain (function org-roam--capture-get-point)
                 "%?"
                 :file-name "%(format-time-string \"%Y-%m-%d--%H-%M-%SZ--journal\" (current-time) t)"
                 :head "#+TITLE: Journal %<%Y-%m-%d>\n#+DATE: %<%Y-%m-%d>\n#+ROAM_ALIAS:\n#+ROAM_TAGS: private journal\n\n"
                 :unnarrowed t))))

  (setq org-roam-completion-system 'helm)

  ;; Use writeroom mode when capturing new notes. Hide the ugly
  ;; preamble of org attributes by scrolling up.
  (defun my/note-taking-init (&rest r)
    (with-current-buffer (current-buffer)
      (writeroom-mode)
      (scroll-up-command 4)))

(use-package company-org-roam
  :ensure t
  :config
  (push 'company-org-roam company-backends))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; Macro for running a function repeatedly in the back ground
;; https://github.com/punchagan/dot-emacs/blob/master/punchagan.org
(defmacro run-with-timer-when-idle (secs idle-time repeat-time function &rest args)
  "Run a function on timer, but only when idle."
  `(run-with-timer
    ,secs
    ,repeat-time
    (lambda () (run-with-idle-timer ,idle-time nil ,function ,@args))))

;; Use golden ratio mode which automatically resizes buffers based on
;; the golden ratio
(use-package golden-ratio
  :ensure t
  :config
  ;; (golden-ratio-mode 1)
  ;; (setq golden-ratio-auto-scale nil)
  (defadvice previous-multiframe-window
      (after golden-ratio-resize-window)
    (golden-ratio) nil))

;; Much better terminal emulator. Requires that emacs is installed
;; --with-modules to work.
; (use-package vterm)

(defun new-term (buffer-name)
  "Start a terminal and rename buffer."
  (interactive "sbuffer name: ")
  (vterm)
  (rename-buffer buffer-name t))

;; Shortcut to create a new term
(define-key global-map (kbd "C-x M-t") 'new-term)

;; Speed up ansi-term in emacs 24.x by skipping guessing left-to-right input
(add-hook 'term-mode-hook 'my-term-mode-hook)
(defun my-term-mode-hook ()
  (setq bidi-paragraph-direction 'left-to-right))

;; Shortcut to jump word and ignore underscore
(define-key global-map (kbd "M-F") 'forward-sexp)
(define-key global-map (kbd "M-B") 'forward-sexp)

;; Highlight changes is removed after save
(defun highlight-changes-remove-after-save ()
  "Remove previous changes after save."
  (make-local-variable 'after-save-hook)
  (add-hook 'after-save-hook
            (lambda ()
              (highlight-changes-remove-highlight (point-min) (point-max)))))

;; Center text
(defun center-text ()
  "Center the text in the middle of the buffer. Works best in full screen"
  (interactive)
  (set-window-margins (car (get-buffer-window-list (current-buffer) nil t))
                        (/ (window-width) 4)
                        (/ (window-width) 4)))

(defun center-text-clear ()
  (interactive)
  (set-window-margins (car (get-buffer-window-list (current-buffer) nil t))
                        nil
                        nil))

(setq centered nil)

(defun center-text-mode ()
  (interactive)
  (make-local-variable 'centered)
  (if (eq centered t)
    (progn (center-text-clear)
           (setq centered nil))
    (progn (center-text)
           (setq centered t))))

(define-key global-map (kbd "C-c M-t") 'center-text-mode)

;; Enable system clipboard
(setq x-select-enable-clipboard t)

;; Stackoverflow plugin
(use-package sos 
  :ensure t)

;; Start emacs without all the fanfare
(setq inhibit-startup-echo-area-message t)
(setq inhibit-startup-message t)

;; Rename file and buffer in one shot
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

;; ido

;; Make sure we are using ido mode
(use-package ido
  :ensure t
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (setq ido-everywhere t)
  (ido-mode (quote both))
  (setq ido-use-faces t)
  ;; Don't magically search for a file that doesn't exist
  (setq ido-auto-merge-work-directories-length -1))

;; Use ido inside ido buffer too
(use-package flx-ido
  :ensure t
  :config
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)

  (setq ido-max-directory-size 100000)

  ;; Use the current window when visiting files and buffers with ido
  (setq ido-default-file-method 'selected-window)
  (setq ido-default-buffer-method 'selected-window)

  ;; Disable minibuffer exit for ido
  (put 'ido-exit-minibuffer 'disabled nil)

  ;; Display ido results vertically, rather than horizontally
  (setq ido-decorations (quote ("\n====> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
  (defun ido-disable-line-truncation ()
    (set (make-local-variable 'truncate-lines) nil))
  (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)

  ;; Use normal up/down keyboard shortcuts
  (defun ido-define-keys ()
    (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
    (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
  (add-hook 'ido-setup-hook 'ido-define-keys))

;; Shells should have color
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Json mode
(use-package json-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
  (add-hook 'json-mode 'flymake-json-load))

;; Fix pasting from a buffer to term
(defun my-term-paste (&optional string)
  (interactive)
  (process-send-string
   (get-buffer-process (current-buffer))
   (if string string (current-kill 0))))

(defun my-term-hook ()
  (goto-address-mode)
  (define-key term-raw-map "\C-y" 'my-term-paste))

(add-hook 'term-mode-hook 'my-term-hook)

;; Shortcut for incrementing and decrementing a number under the cursor
(defun increment-number-at-point ()
  (interactive)
  (skip-chars-backward "-0123456789")
  (or (looking-at "[-0123456789]+")
      (error "No number at point"))
  (replace-match (number-to-string (10+ (string-to-number (match-string 0))))))

(defun decrement-number-at-point ()
  (interactive)
  (skip-chars-backward "-0123456789")
  (or (looking-at "[-0123456789]+")
      (error "No number at point"))
  (replace-match (number-to-string (1- (string-to-number (match-string 0))))))

(defun increment-and-eval-block ()
  (interactive)
  (increment-number-at-point)
  (nrepl-eval-expression-at-point))

(defun decrement-and-eval-block ()
  (interactive)
  (decrement-number-at-point)
  (nrepl-eval-expression-at-point))

(global-set-key (kbd "C-c +") 'increment-and-eval-block)
(global-set-key (kbd "C-c -") 'decrement-and-eval-block)

;; Set a redo command
(global-set-key (kbd "C-x M-r") 'repeat-complex-command)

(defun describe-last-function ()
  (interactive)
    (describe-function last-command))

;; Save a recorded macro with a name
(defun save-macro (name)
  "Takes a name as argument and save the last defined macro under
   this name at the end of your .emacs"
  (interactive "SName of the macro :")  ; ask for the name of the
                                        ; macro
  (kmacro-name-last-macro name)         ; use this name for
                                        ; the macro
  (find-file user-init-file)            ; open ~/.emacs
                                        ; or other user init file
  (goto-char (point-max))               ; go to
                                        ; the end of the .emacs
  (newline)                             ; insert a newline
  (insert-kbd-macro name)               ; copy the macro
  (newline)                             ; insert a newline
  (switch-to-buffer nil))               ; return to the initial buffer

;; Growl integration
(defvar growlnotify-command
  (executable-find "growlnotify")
  "/usr/local/bin/growlnotify")

(defun growl (title message)
  "Shows a message through the growl notification system using
 `growlnotify-command` as the program."
  (cl-flet ((encfn (s) (encode-coding-string s (keyboard-coding-system))))
    (let* ((process (start-process "growlnotify" nil
                                   growlnotify-command
                                   (encfn title)
                                   "-a" "Emacs"
                                   "-n" "Emacs")))
      (process-send-string process (encfn message))
      (process-send-string process "\n")
      (process-send-eof process)))
  t)

;; IRC
(add-hook 'erc-join-hook 'bitlbee-identify)
(defun bitlbee-identify ()
  "If we're on the bitlbee server, send the identify command to the
 &bitlbee channel."
  (when (and (string= "localhost" erc-session-server)
             (string= "&bitlbee" (buffer-name)))
    (erc-message "PRIVMSG" (format "%s identify %s"
                                   (erc-default-target)
                                   bitlbee-password))))

;; Growl notification when mentioned in ERC
(defun erc-growl-hook (match-type nick message)
  "Shows a growl notification, when user's nick was mentioned. If the buffer is currently not visible, makes it sticky."
  (growl
   (concat "ERC: new message on: " (buffer-name (current-buffer)))
   message)
  ;; (unless (posix-string-match "^\\** *Users on #" message)
  ;;   (growl
  ;;    (concat "ERC: name mentioned on: " (buffer-name (current-buffer)))
  ;;    message))
  )

(add-hook 'erc-text-matched-hook 'erc-growl-hook)

;; Projectile
(use-package projectile
  :ensure t
  :config
  (projectile-mode)
  ;; Set the base keybinding
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  ;; Cache projectile projects
  (setq projectile-enable-caching t)
  ;; Defer to git if possible
  (setq projectile-indexing-method 'alien)
  ;; Limit projectile projects to these directories
  (setq projectile-project-search-path '("~/Projects/"))

  (defun projectile-term ()
    "Create an vterm at the project root"
    (interactive)
    (let ((root (projectile-project-root))
	  (buff-name (concat
		      (nth 1 (reverse (split-string (projectile-project-root) "/")))
		      " [term]")))
      (if (get-buffer buff-name)
	  (switch-to-buffer-other-window buff-name)
	(progn
	  (split-window-sensibly (selected-window))
	  (other-window 1)
	  (setq default-directory root)
          (vterm)
	  (rename-buffer buff-name t)))))
  (global-set-key (kbd "C-x M-t") 'projectile-term)

  (defun projectile-notes ()
    "Open org notes file at project root"
    (interactive)
    (let ((root (projectile-project-root))
	  (buff-name (concat
		      (nth 1 (reverse (split-string (projectile-project-root) "/")))
		      "notes.org")))
      (if (get-buffer buff-name)
	  (switch-to-buffer-other-window buff-name)
	(progn
          (if (file-exists-p (concat (projectile-project-root) "notes.org"))
              (progn
                (split-window-sensibly (selected-window))
                (other-window 1)
                (setq default-directory root)
                (find-file (concat root "notes.org")))
            (error "Notes file not found in this project"))))))
  (global-set-key (kbd "C-x M-n") 'projectile-notes))

;; Use ripgrep with projectile
(use-package projectile-ripgrep
  :ensure t
  :config
  (global-set-key (kbd "C-c p s r") 'projectile-ripgrep))

;; Use helm projectile
(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)

  ;; Speed up helm flx matching
  (defvar helm-ido-like-user-gc-setting nil)

  (defun helm-ido-like-higher-gc ()
    (setq helm-ido-like-user-gc-setting gc-cons-threshold)
    (setq gc-cons-threshold most-positive-fixnum))

  (defun helm-ido-like-lower-gc ()
    (setq gc-cons-threshold helm-ido-like-user-gc-setting))

  (defun helm-ido-like-load-fuzzy-enhancements ()
    (add-hook 'minibuffer-setup-hook #'helm-ido-like-higher-gc)
    (add-hook 'minibuffer-exit-hook #'helm-ido-like-lower-gc))

  ;; Use ripgrep with helm
  (setq helm-ag-base-command "rg --vimgrep --no-heading")
  ;; Fix helm projectile when using rg...
  ;; https://github.com/syohex/emacs-helm-ag/issues/283
  (defun helm-projectile-ag (&optional options)
    "Helm version of projectile-ag."
    (interactive (if current-prefix-arg (list (read-string "option: " "" 'helm-ag--extra-options-history))))
    (if (require 'helm-ag nil  'noerror)
	(if (projectile-project-p)
	    (let ((helm-ag-command-option options)
                (current-prefix-arg nil))
	      (helm-do-ag (projectile-project-root) (car (projectile-parse-dirconfig-file))))
	  (error "You're not in a project"))
      (error "helm-ag not available"))))

(use-package helm-rg
  :ensure t
  :config
  ;; Add actions for inserting org file link from selected match
  (defun insert-org-mode-link-from-helm-result (candidate)
    (interactive)
    (with-helm-current-buffer
      (insert (format "[[file:%s][%s]]"
                      (plist-get candidate :file)
                      ;; Extract the title from the file name
                      (subst-char-in-string
                       ?_ ?\s
                       (first
                        (split-string
                         (first
                          (last
                           (split-string (plist-get candidate :file) "\\-")))
                         "\\.")))))))

  (helm-add-action-to-source "Insert org-mode link"
                             'insert-org-mode-link-from-helm-result
                             helm-rg-process-source))

;; browse-kill-ring with M-y
(use-package browse-kill-ring
  :ensure t
  :config
  (browse-kill-ring-default-keybindings))

;; Prevent accidental upcase/downcase
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Unload a theme before enabling another
(defadvice load-theme (before theme-dont-propagate activate)
  (mapc #'disable-theme custom-enabled-themes))

;; Use doom theme
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-org-config)
  (load-theme 'doom-oceanic-next t))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

(use-package all-the-icons 
  :ensure t)

;; Set default font
;; When using gui emacs with emacsclient, the following makes sure the
;; window is opened with the correct font size otherwise it will
;; revert to 13px for font size
(add-to-list 'default-frame-alist '(font . "Sarasa Mono CL 14"))
;; Make the default face the same font
(set-face-attribute 'default t :font "Sarasa Mono CL 14")
(set-face-attribute 'default nil :height 120)

;; Keyboard shortcut for using a big screen
(setq big-screen nil)

(defun toggle-big-screen ()
  (interactive)
  (if big-screen
      (progn
	(setq big-screen nil)
	(set-face-attribute 'default nil :height 120))
    (progn
      (set-face-attribute 'default nil :height 160)
      (setq big-screen 1))))
(global-set-key (kbd "C-x M-b") 'toggle-big-screen)

;; 用GUI tooltips来显示检查到的错误
(progn
  (use-package 
  flycheck-posframe 
  :ensure t 
  :custom-face (flycheck-posframe-border-face ((t 
                          (:inherit default)))) 
  :hook (flycheck-mode . flycheck-posframe-mode) 
  :init (setq flycheck-posframe-border-width 1 flycheck-posframe-inhibit-functions '((lambda 
                                             (&rest _) 
                                             (bound-and-true-p
                                              company-backend))))) 
  (use-package 
  flycheck-pos-tip 
  :ensure t 
  :defines flycheck-pos-tip-timeout 
  :hook (global-flycheck-mode . flycheck-pos-tip-mode) 
  :config (setq flycheck-pos-tip-timeout 30)) 
  (use-package 
  flycheck-popup-tip 
  :ensure t 
  :hook (flycheck-mode . flycheck-popup-tip-mode)))

;; Store customizations in a separate file
(setq custom-file "~/.emacs.d/.customizations.el")
(load custom-file t)

(provide 'init)