(defun evil/window-vsplit-and-follow ()
  "Split current window vertically, then focus new window.
If `evil-vsplit-window-right' is non-nil, the new window isn't focused."
  (interactive)
  (let ((evil-vsplit-window-right (not evil-vsplit-window-right)))
    (call-interactively #'evil-window-vsplit)))

(defun evil/window-split-and-follow ()
  "Split current window horizontally, then focus new window.
If `evil-split-window-below' is non-nil, the new window isn't focused."
  (interactive)
  (let ((evil-split-window-below (not evil-split-window-below)))
    (call-interactively #'evil-window-split)))

(defun myrc/get-project-root ()
  (when (fboundp 'projectile-project-root)
    (projectile-porject-root)))

(defun myrc/project-reset-compilation-path ()
  (interactive)
  (setq compilation-search-path (list (project-root (project-current))))
  (message "Project compilation search path set to: %s" compilation-search-path))

(defun myrc/inferior-process-mode ()
  (setq scroll-margin 0)
  (display-line-numbers-mode 0))

(defun myrc/display-startup-time ()
  "Display emacs startup time and garbage collection."
  (interactive)
  (message
   "Emacs loaded in %s with %d garbage collections."
   (format
    "%.2f seconds"
    (float-time
     (time-subtract after-init-time before-init-time)))
   gcs-done))

(defun myrc/keychain-refresh-environment ()
  "Set ssh-agent and gpg-agent environment variables.
Set the environment variables `SSH_AUTH_SOCK', `SSH_AGENT_PID'
and `GPG_AGENT' in Emacs' `process-environment' according to
information retrieved from files created by the keychain script."
  (interactive)
  (let* ((ssh (shell-command-to-string "keychain -q --noask --eval")))
    (list (and ssh
	       (string-match "SSH_AUTH_SOCK[=\s]\\([^\s;\n]*\\)" ssh)
	       (setenv       "SSH_AUTH_SOCK" (match-string 1 ssh)))
	  (and ssh
	       (string-match "SSH_AGENT_PID[=\s]\\([0-9]*\\)?" ssh)
	       (setenv       "SSH_AGENT_PID" (match-string 1 ssh))))))

(defun myrc/git-project-finder (dir)
  "Integrate .git project roots."
  (let ((dotgit (and (setq dir (locate-dominating-file dir ".git"))
		     (expand-file-name dir))))
    (and dotgit
	 (cons 'transient (file-name-directory dotgit)))))

;; https://github.com/oantolin/embark/wiki/Additional-Configuration#use-which-key-like-a-key-menu-prompt
(defun myrc/embark-which-key-indicator ()
  "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
  (lambda (&optional keymap targets prefix)
    (if (null keymap)
	(which-key--hide-popup-ignore-command)
      (which-key--show-keymap
       (if (eq (plist-get (car targets) :type) 'embark-become)
	   "Become"
	 (format "Act on %s '%s'%s"
		 (plist-get (car targets) :type)
		 (embark--truncate-target (plist-get (car targets) :target))
		 (if (cdr targets) "…" "")))
       (if prefix
	   (pcase (lookup-key keymap prefix 'accept-default)
	     ((and (pred keymapp) km) km)
	     (_ (key-binding prefix 'accept-default)))
	 keymap)
       nil nil t (lambda (binding)
		   (not (string-suffix-p "-argument" (cdr binding))))))))

(defun myrc/embark-hide-which-key-indicator (fn &rest args)
  "Hide the which-key indicator immediately when using the completing-read prompter."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
	 (remq #'embark-which-key-indicator embark-indicators)))
    (apply fn args)))

(defun myrc/desktop-save-autoconfirm (orig-fn &rest args)
  "Advice to autoconfirm when saving desktop state."
  (apply orig-fn args))

(defun myrc/evil-yank-pulse (orig-fn beg end &rest args)
  "Advice to add momentary pulse upon yank."
  (pulse-momentary-highlight-region beg end)
  (apply orig-fn beg end args))

(defun myrc/frame-title ()
  "Set frame title and server name."
  (unless (boundp 'server-name)
    (setq server-name "standalone"))
  (setq frame-title-format (concat "%b - [" server-name "]"))
  (setq global-mode-string (concat "[" server-name "]")))

(defcustom myrc/compilation-window-kill-on-success-var nil
  "Close compilation window on success."
  :type 'boolean)

(defun myrc/toggle-compilation-window-kill-on-success ()
  "Toggle myrc/compilation-window-kill-on-success."
  (interactive)
  (setq myrc/compilation-window-kill-on-success-var
	(not myrc/compilation-window-kill-on-success-var))
  (message "Set myrc/compilation-window-kill-on-success-var to %s" myrc/compilation-window-kill-on-success-var))

(defun myrc/compilation-window-kill-on-success (buf str)
  "Hook for myrc/compilation-window-kill-on-success.
Needs to contain a `finished' message, as well as have 0 errors, warnings and infos. Can be toggled."
  (interactive)
  (if (and (not (null (string-match ".*finished.*" str)))
	   compilation-num-errors-found
	   compilation-num-infos-found
	   compilation-num-warnings-found
	   myrc/compilation-window-kill-on-success-var)
      ;; no errors; kill compilation window
      (progn (delete-windows-on
	      (get-buffer-create "*compilation*"))
	     (message "Compilation finished successfully"))))

(defun myrc/yank-file-name (full)
  "Place filename in kill-ring. Only filename if FULL is nil, else full path."
  (interactive)
  (let ((filename (if full
		      (buffer-file-name)
		    (f-filename (buffer-file-name)))))
    (kill-new filename)
    (message filename)))

(defun myrc/journal (&optional write)
  "Open journal and add a new heading for tomorrow's date"
  (interactive)
  (find-file "~/notes/journal/again.org")
  (let ((inhibit-message t))
    (when write
      (org-insert-heading-respect-content)
      (insert (format-time-string "%A (%d/%m/%y)"
				  (time-add (current-time) (* 60 60 24)))))))

(defun myrc/desktop-save (&optional RELEASE ONLY-IF-CHANGED VERSION)
  "My version of desktop-save that sets DIRNAME automatically."
  ;; Create dir if it doesn't exist
  (unless (f-exists-p desktop-dirname)
    (make-directory desktop-dirname))
  ;; Delete existing .desktop file if it exists
  (when (f-exists-p (desktop-full-file-name))
    (delete-file (desktop-full-file-name)))
  ;; Save temp buffers
  (myrc/save-temp-buffers)
  (when
      (desktop-save desktop-dirname RELEASE ONLY-IF-CHANGED VERSION)
    (message "%s saved successfully in %s" desktop-base-file-name desktop-dirname)))

(defun myrc/desktop-read (&optional DIRNAME CHOOSE)
  "My version of desktop-read with a little extra logic.
Better programming practice would be to break down this function into a few
small ones that are easier to understand and debug."
  (if
      (or CHOOSE DIRNAME)
      (when ;; At least one of the variables is bound
	  (and ;; Respect DIRNAME if both are bound
	   CHOOSE
	   (not DIRNAME))
	(let ((DIRNAME (read-directory-name "Desktop save location: " myrc/desktop-save-location))) ;; Only prompt if DIRNAME is empty
	  (if
	      (and ;; Sanity check on DIRNAME
	       (stringp DIRNAME)
	       (f-exists-p (concat DIRNAME server-name ".desktop")))
	      (desktop-read DIRNAME)
	    (desktop-read desktop-dirname))))
    (desktop-read))) ;; Neither variable is bound

(defun myrc/desktop-delete-dangling-locks ()
  "Recursively delete all '.lock$' files in 'myrc/desktop-save-location."
  (mapc
   'delete-file
   (directory-files-recursively myrc/desktop-save-location ".lock$")))

(defun myrc/kill-emacs (&optional SAVE-STATE CONFIRM-KILL-PROCESSES)
  "Gracefully kill emacs after saving buffers. If FORCE is t, then save desktop state as well."
  (interactive)
  (when SAVE-STATE
    (myrc/desktop-save t t))
  (let ((current-prefix-arg 4) ;; simulate call with universal prefix (C-u/SPC-u)
	(confirm-kill-processes CONFIRM-KILL-PROCESSES))
    (call-interactively #'save-buffers-kill-emacs)))

(defun myrc/iedit-restrict-region-if-selected ()
  (let ((bounds (car (region-bounds))))
    (when (use-region-p)
      (progn
	(message "Region is active")
	(iedit-restrict-region (car bounds) (cdr bounds))))))

(defun myrc/toggle-theme ()
  "Toggle between a light and dark theme."
  (interactive)
  (if (eq myrc/theme-light (car custom-enabled-themes))
      (progn
	(load-theme myrc/theme-dark t)
	(disable-theme myrc/theme-light))
    (progn
      (load-theme myrc/theme-light t)
      (disable-theme myrc/theme-dark))))

(defun myrc/start-eglot ()
  "Start eglot with my own config"
  (interactive)
  (progn
    (eglot-ensure)
    (add-hook 'eglot-managed-mode-hook
	      (lambda ()
		(progn
		  (remove-hook 'flymake-diagnostic-functions 'eglot-flymake-backend)
		  (eglot-inlay-hints-mode -1)
		  (flymake-mode -1)
		  (setq eldoc-documentation-strategy
			'eldoc-documentation-compose-eagerly))))))


(defun myrc/save-temp-buffers ()
  "Save all modified buffers not visiting a file to predefined paths without prompting."
  (let ((temp-dir (expand-file-name
		   (concat
		    "~/.emacs.d/temp-buffers/"
		    (format-time-string "%Y-%m-%d")
		    "/" server-name "/"))))
    ;; Ensure the directory exists
    (unless (file-directory-p temp-dir)
      (make-directory temp-dir t))  ;; Iterate over all buffers
    (dolist (buf (buffer-list))
      (with-current-buffer buf
	;; Check if the buffer is modified and not visiting a file
	(when (and (not buffer-file-name)
		   (buffer-modified-p)
		   (string-prefix-p "*new*" (buffer-name)))
	  ;; Define a unique file name for each buffer
	  (let ((temp-file (expand-file-name (buffer-name) temp-dir)))
	    ;; Save buffer contents to the file without prompting
	    (write-region (point-min) (point-max) temp-file)
	    ;; Mark the buffer as not modified
	    (set-buffer-modified-p nil)
	    (message "Saved buffer '%s' to '%s'" (buffer-name) temp-file)
	    ;; Kill temp buffer and open new file so that desktop-save can save and reopen it
	    (kill-buffer buf)
	    (find-file temp-file)))))))

(defun myrc/toggle-window-split ()
  "Toggle window split between horizontal and vertical for two windows."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((windows (window-list))
	     (win1 (nth 0 windows))
	     (win2 (nth 1 windows))
	     (buf1 (window-buffer win1))
	     (buf2 (window-buffer win2))
	     (split-vertically (window-combined-p)))
	(delete-other-windows)
	(if split-vertically
	    (progn
	      (split-window-horizontally)
	      (set-window-buffer (next-window) buf2))
	  (progn
	    (split-window-vertically)
	    (set-window-buffer (next-window) buf2)))
	(set-window-buffer (selected-window) buf1))
    (message "There must be exactly two windows to toggle split orientation.")))
