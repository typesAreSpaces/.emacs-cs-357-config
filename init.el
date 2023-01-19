(require 'package)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(simpleclip yasnippet-snippets yasnippet hydra helpful orderless vertico embark-consult embark marginalia which-key doom-modeline anzu haskell-mode font-lock no-littering use-package)))
(package-initialize)

					; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package no-littering)

;; Basic UI setup
(global-font-lock-mode t)
(show-paren-mode 1)
(put 'upcase-region 'disabled nil)
(put 'eval-expression 'disabled nil)
(scroll-bar-mode -1)               ; Disable visible scrollbar
(tool-bar-mode -1)                 ; Disable the toolbar
(tooltip-mode -1)                  ; Disable tooltips
(set-fringe-mode 10)               ; Give some breathing room
(setq visible-bell t)              ; Set up the visible bell

(set-face-attribute 'default nil :font "Fira Code Retina" :height 180)
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 180)
(set-face-attribute 'variable-pitch nil :font "Hack" :height 180 :weight 'regular)

(use-package command-log-mode
  :commands command-log-mode)

(use-package rainbow-mode)

(use-package rainbow-delimiters
    :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

(use-package anzu)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (
	   (doom-modeline-height 15)
	   (doom-modeline-enable-word-count t)
	   (doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode text-mode))))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

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
	completion-category-overrides '((file (styles partial-completion)))))

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
	 ("C-c C-b" . consult-buffer)                ; orig. switch-to-buffer
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

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package yasnippet
    :config
    (setq yas-snippet-dirs `(,(expand-file-name "snippets" user-emacs-directory)))
    (setq yas-key-syntaxes '(yas-longest-key-from-whitespace "w_.()" "w_." "w_" "w"))
    (yas-global-mode 1))

(use-package yasnippet-snippets)

(use-package simpleclip
    :config
    (simpleclip-mode 1))

;; Basic Racket setup
(setq scheme-program-name "racket")
(setq auto-mode-alist
      (cons '("\\.rkt\\'" . scheme-mode)
	    auto-mode-alist))

;; Basic Haskell setup
(use-package haskell-mode
  :config
  (setq haskell-program-name "/opt/homebrew/bin/ghci")
  (setq auto-mode-alist
	(cons '("\\.hs\\'" . haskell-mode)
	      auto-mode-alist))
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  ;; Choose indentation mode (the latter requires haskell-mode >= 2.5):
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
  ;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
