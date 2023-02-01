(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;(global-font-lock-mode t)
(show-paren-mode 1)
(put 'upcase-region 'disabled nil)
(put 'eval-expression 'disabled nil)
(scroll-bar-mode -1)               ; Disable visible scrollbar
(tool-bar-mode -1)                 ; Disable the toolbar
(tooltip-mode -1)                  ; Disable tooltips
(menu-bar-mode -1)                 ; Disable the menu bar
(set-fringe-mode 10)               ; Give some breathing room
(setq visible-bell t)              ; Set up the visible bell
(winner-mode 1)                    ; Enable winner mode

(defun frame-font-setup
    (&rest ...)
  ;; (remove-hook 'focus-in-hook #'frame-font-setup)
  (unless (assoc 'font default-frame-alist)
    (let* ((font-family (catch 'break
                          (dolist (font-family
                                   '("Fira Code"
                                     "Hack"
                                     "Consolas"))
                            (when (member font-family (font-family-list))
                              (throw 'break font-family)))))
           (font (when font-family (format "%s-18" font-family))))
      (when font
        (add-to-list 'default-frame-alist (cons 'font font))
        (set-frame-font font t t)))))

(add-hook 'focus-in-hook #'frame-font-setup)

(global-set-key "%" 'match-paren)

(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(set-face-attribute 'default nil :font "Fira Code Retina" :height 160)
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 160)
(set-face-attribute 'variable-pitch nil :font "Hack" :height 160 :weight 'regular)

(use-package no-littering)

(use-package command-log-mode
  :commands command-log-mode)

(use-package rainbow-mode)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-themes
  :init (load-theme 'doom-zenburn t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (
           (doom-modeline-height 15)
           (doom-modeline-enable-word-count t)
           (doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode text-mode))))

(use-package anzu) 

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1)
  (which-key-enable-god-mode-support))

(defvar dashboard-logo-path "~/Pictures/Wallpapers/figures/480px-EmacsIcon.svg.png")

(use-package all-the-icons)

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-banner-logo-title "Welcome to Emacs!")
  (when (file-exists-p dashboard-logo-path)
    (setq dashboard-startup-banner dashboard-logo-path))
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 10)))
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

                                        ;(with-eval-after-load 'dashboard (dashboard-refresh-buffer))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t)) 

(use-package simpleclip
  :config
  (simpleclip-mode 1))

(defun org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
                                        ; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'org-babel-tangle-config)))

(use-package general
  :config
  (general-create-definer leader-keys
    :prefix "C-c SPC")

  (leader-keys
    "e" '(:ignore t :which-key "(e)dit buffer")
    "ef"  '(fill-buffer :which-key "(f)ill buffer")
    "ei"  '((lambda () (interactive) (indent-region (point-min) (point-max))) :which-key "(i)ndent buffer")
    "ey" '(simpleclip-copy :which-key "clipboard (y)ank")
    "ep" '(simpleclip-paste :which-key "clipboard (p)aste")
    "f" '(:ignore t :which-key "edit (f)iles")
    "fa" '((lambda () (interactive)
             (find-file (expand-file-name "~/Documents/GithubProjects/phd-thesis/Documents/Semesters/2023/Spring/TA-CS-357/Org-Files/current_tasks.org")))
           :which-key "TA (a)genda")
    "fe" '((lambda () (interactive)
             (find-file (expand-file-name "~/Documents/GithubProjects/.emacs-cs-357-config/cs-357.org")))
           :which-key "(e)macs config file")
    "s"  '(shell-command :which-key "(s)hell command")
    "t"  '(:ignore t :which-key "(t)oggles")
    "tt" '(load-theme :which-key "Choose (t)heme")
    "d" '(dired-jump :which-key "(d)ired jump")
    "w" '(:ignore t :which-key "(w)indows related")
    "wu" '(winner-undo :which-key "Winner (u)ndo")
    "wr" '(winner-redo :which-key "Winner (r)edo")))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package god-mode
  :init
  (god-mode)
  :config
  (global-set-key (kbd "s-g") #'god-mode-all)
  (define-key god-local-mode-map (kbd "i") #'god-local-mode)
  (global-set-key (kbd "C-g") (lambda () (interactive) (prog1 (god-local-mode) (keyboard-quit))))
  (setq god-mode-enable-function-key-translation nil)
  (setq god-exempt-major-modes nil)
  (setq god-exempt-predicates nil))

(use-package flx)

(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (require 'embark)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode)
  :init
  (with-eval-after-load 'embark
    (require 'embark-consult)))

(use-package vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("C-h" . vertico-directory-delete-word))
  :init
  (vertico-mode))

(use-package orderless
  :demand t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))
  :config
  (setq orderless-matching-styles '(orderless-flex)))

(use-package consult
  :after (vertico)
                                        ; Replace bindings. Lazily loaded due by `use-package'.
  :bind (; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ; orig. repeat-complex-command
         ("C-x 4 b" . consult-buffer-other-window) ; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ; orig. project-switch-to-buffer
                                        ; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
                                        ; Other custom bindings
         ("M-y" . consult-yank-pop)                ; orig. yank-pop
         ("<help> a" . consult-apropos)            ; orig. apropos-command
                                        ; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ; orig. goto-line
         ("M-g o" . consult-outline)               ; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
                                        ; M-s bindings (search-map)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
                                        ; C-c bindings
         ("C-x C-b" . consult-buffer)                ; orig. switch-to-buffer
         ("C-s"     . consult-line)
         ("C-c C-f" . consult-find)
         ("C-c D" . consult-locate)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ("C-c C-g" . consult-grep)
                                        ; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ; needed by consult-line to detect isearch
                                        ; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ; orig. next-matching-history-element
         ("M-r" . consult-history))                ; orig. previous-matching-history-element

                                        ; Enable automatic preview at point in the *Completions* buffer. This is
                                        ; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

                                        ; The :init configuration is always executed (Not lazy)
  :init

                                        ; Optionally configure the register formatting. This improves the register
                                        ; preview for `consult-register', `consult-register-load',
                                        ; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

                                        ; Optionally tweak the register preview window.
                                        ; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

                                        ; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

                                        ; Configure other variables and modes in the :config section,
                                        ; after lazily loading the package.
  :config
  (consult-customize consult--source-buffer :hidden t :default nil)
  (setq consult-project-root-function (lambda () (project-root (project-current))))
                                        ; Optionally configure preview. The default value
                                        ; is 'any, such that any key triggers the preview.
                                        ; (setq consult-preview-key 'any)
                                        ; (setq consult-preview-key (kbd "M-."))
                                        ; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
                                        ; For some commands and buffer sources it is useful to configure the
                                        ; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   :preview-key (kbd "M-."))

                                        ; Optionally configure the narrowing key.
                                        ; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ; (kbd "C-+")

                                        ; Optionally make narrowing help available in the minibuffer.
                                        ; You may want to use `embark-prefix-help-command' or which-key instead.
                                        ; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

                                        ; By default `consult-project-function' uses `project-root' from project.el.
                                        ; Optionally configure a different project root function.
                                        ; There are multiple reasonable alternatives to chose from.
                                        ; 1. project.el (the default)
                                        ; (setq consult-project-function #'consult--default-project--function)
                                        ; 2. projectile.el (projectile-project-root)
                                        ; (autoload 'projectile-project-root "projectile")
                                        ; (setq consult-project-function (lambda (_) (projectile-project-root)))
                                        ; 3. vc.el (vc-root-dir)
                                        ; (setq consult-project-function (lambda (_) (vc-root-dir)))
                                        ; 4. locate-dominating-file
                                        ; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  )

(defun consult-grep-current-dir ()
  "Call `consult-grep' for the current buffer (a single file)."
  (interactive)
  (let ((consult-project-function (lambda (x) "./")))
    (consult-grep)))

(defun consult-find-current-dir ()
  "Call `consult-find' for the current buffer (a single file)."
  (interactive)
  (let ((consult-project-function (lambda (x) "./")))
    (consult-find)))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package yasnippet
  :config
  (setq yas-snippet-dirs `(,(expand-file-name "snippets" user-emacs-directory)))
  (setq yas-key-syntaxes '(yas-longest-key-from-whitespace "w_.()" "w_." "w_" "w"))
  (yas-global-mode 1))

(use-package yasnippet-snippets) 

(load (expand-file-name "snippets/yasnippet-scripts.el" user-emacs-directory))

(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-l")
  :config
  (lsp-enable-which-key-integration t))

(setq scheme-program-name "racket")
(setq auto-mode-alist
      (cons '("\\.rkt\\'" . scheme-mode)
            auto-mode-alist))

(defun run-scheme2 ()
  "Run scheme-program-name and disable geiser-mode."
  (interactive)
  (split-window-right)
  (geiser-mode -1)
  (windmove-right)
  (run-scheme scheme-program-name))

(defun run-scheme3 ()
  "Run scheme-program-name and disable geiser-mode."
  (interactive)
  (split-window-right)
  (windmove-right)
  (run-scheme scheme-program-name))

(use-package haskell-mode
  :mode "\\.hs\\'"
                                        ;:hook (haskell-mode . lsp-deferred)
  :config
  (setq haskell-program-name "/opt/homebrew/bin/ghci")
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  ;; Choose indentation mode (the latter requires haskell-mode >= 2.5):
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
  ;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  )
(use-package lsp-haskell)

(defun efs/org-font-setup ()
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Fira Code" :weight 'regular :height (cdr face)))

  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (when (not (version< emacs-version "26.3"))
    (set-face-attribute 'line-number nil :inherit 'fixed-pitch))
  (when (not (version< emacs-version "26.3"))
    (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch)))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-file-apps
        '((auto-mode . emacs)
          (directory . emacs)
          ("\\.mm\\'" . default)
          ("\\.x?html?\\'" . default)
          ("\\.nb?\\'" . "Mathematica %s")
          ("\\.pdf\\'" . "open -a Skim %s")))

  (setq org-ellipsis "⇓")

  (setq org-todo-keywords
        '((sequence "EXTERNAL" "|")
          (sequence "GOAL" "IDEA" "OBSERVATION" "|")
          (sequence "TODAY" "TODO" "LATER" "|" "COMPLETED(c)" "CANC(k@)")
          (sequence "EMAIL" "|")))

  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

  (define-key global-map (kbd "C-c s")
    (lambda () (interactive) (mark-whole-buffer) (org-sort-entries nil ?o)))

  (define-key global-map (kbd "C-c c")
    (lambda () (interactive) (org-todo "COMPLETED")))

  (define-key global-map (kbd "C-c t")
    (lambda () (interactive) (org-todo "TODO")))

  (defun auto/SortTODO ()
    (when (and buffer-file-name (string-match ".*/todolist.org" (buffer-file-name)))
      (setq unread-command-events (listify-key-sequence "\C-c s"))))

  (efs/org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))
