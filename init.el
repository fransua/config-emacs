(setq load-path (cons "~/.emacs.d/lisp"			 load-path))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))


(require 'minimap)

(package-initialize)
(elpy-enable)
;; (setq elpy-rpc-backend "jedi")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backup-file
(setq
   backup-by-copying t                    ; don't clobber symlinks
   backup-directory-alist
   '(("." . "/graves/.sos/backup"))       ; all backed up files wiil be there
   auto-save-file-name-transforms
   `((".*" "/graves/.sos/auto-save/" t))  ; same for auto-saved
   delete-old-versions t                                  
   kept-new-versions 4                    ; keep latest 4 versions
   kept-old-versions 2                    ; keep first 2 (if younger than limit)
   version-control t)                     ; use versioned backups


;; remove old backup files
(message "Checking age of backup files (keeping if less than 2 days)")
 (let ((max-age (* 60 60 24 2))
      (current (float-time (current-time))))
  (dolist (file (directory-files "/graves/.sos/backup" t))
    (when (and (backup-file-name-p file)
               (> (- current (float-time (fifth (file-attributes file))))
                  max-age))
      (message "%s" file)
      (delete-file file))))

;; remove very old auto-save files
(message "Checking age of autosave files (keeping if less than 30 days)")
 (let ((max-age (* 60 60 24 30))
      (current (float-time (current-time))))
  (dolist (file (directory-files "/graves/.sos/auto-save" t))
    (when (and (backup-file-name-p file)
               (> (- current (float-time (fifth (file-attributes file))))
                  max-age))
      (message "%s" file)
      (delete-file file))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flymake-mode
(add-hook 'find-file-hook 'flymake-find-file-hook)
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
		       'flymake-create-temp-inplace))
	   (local-file (file-relative-name
			temp-file
			(file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
	       '("\\.py\\'" flymake-pylint-init))
  )
(setq flymake-run-in-place nil)
(setq flymake-number-of-errors-to-display 4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; moving arround
(global-set-key (kbd "C-M-<up>") 'windmove-up)
(global-set-key (kbd "C-M-<down>") 'windmove-down)
(global-set-key (kbd "C-M-<right>") 'windmove-right)
(global-set-key (kbd "C-M-<left>") 'windmove-left)

;; from the mac
(define-key input-decode-map "\e[1;5A" [C-up])
(define-key input-decode-map "\e[1;5B" [C-down])
(define-key input-decode-map "\e[1;5C" [C-right])
(define-key input-decode-map "\e[1;5D" [C-left])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elpy shortcuts
(global-set-key (kbd "C-<tab>") 'elpy-company-backend)
(global-set-key (kbd "C-!") 'elpy-shell-switch-to-shell)
(global-set-key (kbd "C-c .") 'elpy-goto-definition)
(global-set-key (kbd "C-c :") 'elpy-goto-definition-other-window)
(global-set-key (kbd "C-c ,") 'pop-tag-mark)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(company-auto-complete t)
 '(delete-selection-mode 1)
 '(electric-pair-mode t)
 '(flymake-gui-warnings-enabled t)
 '(fringe-mode (quote (0 . 0)) nil (fringe))
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(python-check-command "pylint")
 '(python-shell-interpreter "ipython")
 '(python-shell-prompt-detect-enabled nil)
 '(pyvenv-mode t)
 '(scroll-bar-mode nil)
 '(setq visible-bell t)
 '(show-paren-mode t)
 '(tool-bar-mode nil nil (tool-bar))
 '(truncate-lines t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; key-bindings
(global-unset-key "\M-g")
(global-set-key "\M-g" 'goto-line)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background "grey5" :foreground "grey85" :height 93))))
 '(flymake-errline ((t (:underline (:color "red" :style line)))))
 '(flymake-warnline ((t (:underline (:color "yellow" :style line)))))
 '(font-lock-builtin-face ((t (:foreground "#e586ff"))))
 '(font-lock-comment-face ((t (:foreground "brown" :slant italic))))
 '(font-lock-constant-face ((t (:foreground "#ff6464"))))
 '(font-lock-function-name-face ((t (:foreground "#fcf08c"))))
 '(font-lock-keyword-face ((t (:foreground "#1a8fff"))))
 '(font-lock-string-face ((t (:foreground "LightGreen"))))
 '(font-lock-type-face ((t (:foreground "#fcf08c" :weight bold))))
 '(font-lock-variable-name-face ((t (:foreground "White" :weight normal))))
 '(show-paren-match ((t (:foreground "green" :background "grey30"))))
 '(show-paren-mismatch ((t (:foreground "red" :background "grey30")))))
 ; class

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; perl replace
(defun perl-replace (start end)
  "Replace a text pattern in a  region using perl expressions"
  (interactive "*r")
  (defvar regexp)
  (defvar to-string)
  (defvar command)
  (setq regexp (read-string "Regexp: "))
  (setq to-string (read-string (concat "[" regexp "] Replacement: ")))
  (setq command (concat "perl -e 's/" regexp "/" to-string "/g' -p"))
  (shell-command-on-region start end command nil 1)
  )
(global-set-key "\M-r" 'perl-replace)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
