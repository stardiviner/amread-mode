;;; amread-mode.el --- A minor mode helper user speed-reading. -*- lexical-binding: t; -*-

;;; Time-stamp: <2020-02-16 15:53:06 stardiviner>

;; Authors: stardiviner <numbchild@gmail.com>
;; Package-Requires: ((emacs "24.3"))
;; Package-Version: 0.1
;; Keywords: wp
;; homepage: https://github.com/stardiviner/amread-mode

;; amread-mode is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; amread-mode is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;; 
;;; Usage
;;;
;;; 1. Launch amread-mode with command `amread-mode'.
;;; 2. Stop amread-mode by pressing [q].

;;; Code:

(defcustom amread-wps 3.0
  "Read words per second."
  :type 'float
  :safe #'floatp
  :group 'amread)

(defvar amread--running nil)
(defvar amread--overlay nil)
(defvar amread--current-position nil)

(defun amread--update ()
  "Moving amread cursor forward."
  (let* ((begin (point))
         (end (point)))
    (if (eobp)
        (progn
          (amread-mode -1)
          (setq amread--current-position nil))
      ;; create the overlay if does not exist
      (unless amread--overlay
        (setq amread--overlay (make-overlay begin end)))
      ;; move overlay forward
      (when amread--overlay
        (move-overlay amread--overlay begin end))
      (setq amread--current-position (point))
      (overlay-put amread--overlay
                   'face '((foreground-color . "white")
                           (background-color . "dark green")))
      (skip-chars-forward "\s\t\n—"))))

(defun amread-start ()
  "Start / resume amread."
  (interactive)
  (read-only-mode 1)
  ;; resume from stopped position
  (if amread--current-position
      (goto-char amread--current-position)
    (goto-char 0))
  (setq amread--running
        (run-with-timer 0 (/ 1.0 amread-wps) #'amread--update))
  (message "I start reading..."))

(defun amread-stop ()
  "Stop amread."
  (interactive)
  (when amread--running
    (cancel-timer amread--running)
    (setq amread--running nil)
    (delete-overlay amread--overlay))
  (read-only-mode -1)
  (message "I stopped reading."))

(defun amread-pause-or-resume ()
  "Pause or resume amread."
  (interactive)
  (if amread--running
      (amread-stop)
    (amread-start)))

(defun amread-mode-quit ()
  "Disable amread-mode."
  (interactive)
  (amread-mode -1))

(defvar amread-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") 'amread-mode-quit)
    (define-key map (kbd "SPC") 'amread-pause-or-resume)
    (define-key map [remap keyaobrd-quit] 'amread-mode-disable)
    map)
  "Keymap for amread-mode buffers.")

(define-minor-mode amread-mode
  "I'm reading mode."
  :init nil
  :lighter " I'm reading "
  :keymap amread-mode-map
  (if amread-mode
      (amread-start)
    (amread-stop)))



(provide 'amread-mode)

;;; amread-mode.el ends here
