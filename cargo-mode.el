(defcustom cargo-path-to-bin
  (or (executable-find "cargo")
      "~/.cargo/bin/cargo")
  "Path to the cargo executable."
  :type 'file
  :group 'cargo-mode)

(defvar cargo-mode--last-command nil "Last cargo command.")

(defun cargo-mode-last-command ()
  "Execute the last cargo-mode task."
  (interactive)
  (if cargo-mode--last-command
      (apply #'cargo-mode--start cargo-mode--last-command)
    (message "Last command is not found.")))

(defun cargo-mode--fetch-cargo-tasks (project-root)
  "Fetches list of raw commands from shell for project in PROJECT-ROOT."
  (interactive "P")
  (let* ((default-directory (or project-root default-directory))
         (cmd (concat (shell-quote-argument cargo-path-to-bin) " --list"))
         (tasks-string (shell-command-to-string cmd))
         (tasks (butlast (cdr (split-string tasks-string "\n")))))
    (delete-dups tasks)))

(defun cargo-mode--available-tasks (project-root)
  "Lists all available tasks in PROJECT-ROOT."
  (interactive "P")
  (let* ((raw_tasks (cargo-mode--fetch-cargo-tasks project-root))
        (result (mapcar #'cargo-mode--format-command raw_tasks)))
    (print result)))

(defun cargo-mode--format-command (raw-command)
  "Splits command and doc string in RAW-COMMAND."
  (let* ((command-words (split-string raw-command))
         (command (car command-words))
         (doc-words (cdr command-words))
         (doc (concat (mapconcat #'identity doc-words " "))))
    (cons command doc)))
