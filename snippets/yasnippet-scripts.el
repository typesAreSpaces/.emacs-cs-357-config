(defun my-yas-try-expanding-auto-snippets ()
    (when yas-minor-mode
      (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
        (yas-expand))))

(add-hook 'post-command-hook #'my-yas-try-expanding-auto-snippets)
