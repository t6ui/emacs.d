;; I'm in Australia now
;; I'm in Australia now
(setq system-time-locale "C")

;; {{ stardict
(setq sdcv-dictionary-simple-list '("�ʵ�Ӣ���ֵ�5.0"))
(setq sdcv-dictionary-complete-list '("WordNet"))
;; }}

;; {{ elpa-mirror
(setq elpamr-default-output-directory "~/myelpa")
(setq elpamr-repository-name "myelpa")
(setq elpamr-repository-path "https://dl.dropboxusercontent.com/u/858862/myelpa/")
(setq elpamr-email "myname@mydomain.com")
;; }}

;; lock my package
(if (file-readable-p (expand-file-name "~/Dropbox/Public/myelpa/archive-contents"))
     (setq package-archives '(("myelpa" . "~/Dropbox/Public/myelpa/"))))

;; {{ Set up third party tags
(defun insert-into-tags-table-list(e)
  (add-to-list 'tags-table-list e t)
  )
(defun delete-from-tags-table-list (e)
  (setq tags-table-list (delete e tags-table-list))
  )

(defun add-wx-tags (&optional del)
  "Add or delete(C-u) wxWidgets tags into tags-table-list"
  (interactive "P")
  (let (mytags)
    ; here add your third party tags
    (setq mytags (list "~/tags/wx/osx/TAGS"))
    (if del (mapc 'delete-from-tags-table-list mytags)
      (mapc 'insert-into-tags-table-list mytags)
      )
    )
  )
;; }}

;; (getenv "HOSTNAME") won't work because $HOSTNAME is not an env variable
;; (system-name) won't work because as Optus required, my /etc/hosts is changed
(defun my/at-office ()
  (interactive)
  (let ((my-hostname (with-temp-buffer
                       (shell-command "hostname" t)
                       (goto-char (point-max))
                       (delete-char -1)
                       (buffer-string))
                     ))
    (and (string= my-hostname "my-sydney-workpc")
         (not (or (string= my-hostname "sydneypc")
                  (string= my-hostname "ChenBinMacAir")
                  (string= my-hostname "eee")
                  )))
    ))

(defun my/use-office-style ()
  (interactive)
  (let ((dir (if (buffer-file-name)
                 (file-name-directory (buffer-file-name))
               "")))
    (string-match-p "CompanyProject" dir)
    ))

(defun my/setup-develop-environment ()
  (cond
   ((my/use-office-style)
    (message "Office code style!")
    (setq coffee-tab-width 4)
    (setq javascript-indent-level 4)
    (setq js-indent-level 4)
    (setq js2-basic-offset 4)
    (setq web-mode-indent-style 4))
   (t
    (message "My code style!")
    (setq coffee-tab-width 4)
    (setq javascript-indent-level 2)
    (setq js-indent-level 2)
    (setq js2-basic-offset 2)
    (setq web-mode-indent-style 2))
   ))

(add-hook 'js2-mode-hook 'my/setup-develop-environment)
(add-hook 'web-mode-hook 'my/setup-develop-environment)

(my/setup-develop-environment)

;; {{ gnus setup
(require 'nnir)

;; ask encyption password once
(setq epa-file-cache-passphrase-for-symmetric-encryption t)


;;@see http://www.emacswiki.org/emacs/GnusGmail#toc1
;; (add-to-list 'gnus-secondary-select-methods '(nntp "news.gmane.org"))
;; (add-to-list 'gnus-secondary-select-methods '(nntp "news.gwene.org"))
(if (my/at-office)
    (add-to-list 'gnus-secondary-select-methods '(nnml "optus"))
    (setq mail-sources
      '((pop :server "localhost"
         :port 1110
         :user "CP111111"
         :password "MyPassword"
         :stream network)))
    )


(setq gnus-select-method
             '(nnimap "gmail"
                      (nnimap-address "imap.gmail.com")
                      (nnimap-server-port 993)
                      (nnimap-stream ssl)
                      (nnir-search-engine imap)
                      (nnimap-authinfo-file "~/.authinfo.gpg")
                      ; @see http://www.gnu.org/software/emacs/manual/html_node/gnus/Expiring-Mail.html
                      ;; press 'E' to expire email
                      (nnmail-expiry-target "nnimap+gmail:[Gmail]/Trash")
                      (nnmail-expiry-wait 90)
                      ))

;;@see http://gnus.org/manual/gnus_397.html
;; (add-to-list 'gnus-secondary-select-methods
;;              )

(setq-default
  gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f  %B%s%)\n"
  gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
  gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
  gnus-sum-thread-tree-false-root ""
  gnus-sum-thread-tree-indent ""
  gnus-sum-thread-tree-leaf-with-other "-> "
  gnus-sum-thread-tree-root ""
  gnus-sum-thread-tree-single-leaf "|_ "
  gnus-sum-thread-tree-vertical "|")
(setq gnus-thread-sort-functions
      '(
        (not gnus-thread-sort-by-date)
        (not gnus-thread-sort-by-number)
        ))

;; we want to browse freely from gwene (RSS)
(setq gnus-safe-html-newsgroups "\\`nntp[+:]news\\.gwene\\.org[+:]")

; NO 'passive
(setq gnus-use-cache t)
(setq gnus-use-adaptive-scoring t)
(setq gnus-save-score t)
(add-hook 'mail-citation-hook 'sc-cite-original)
(add-hook 'message-sent-hook 'gnus-score-followup-article)
(add-hook 'message-sent-hook 'gnus-score-followup-thread)
; @see http://stackoverflow.com/questions/945419/how-dont-use-gnus-adaptive-scoring-in-some-newsgroups
(setq gnus-parameters
      '(("nnimap.*"
         (gnus-use-scoring nil)) ;scoring is annoying when I check latest email
        ))

(defvar gnus-default-adaptive-score-alist
  '((gnus-kill-file-mark (from -10))
    (gnus-unread-mark)
    (gnus-read-mark (from 10) (subject 30))
    (gnus-catchup-mark (subject -10))
    (gnus-killed-mark (from -1) (subject -30))
    (gnus-del-mark (from -2) (subject -15))
    (gnus-ticked-mark (from 10))
    (gnus-dormant-mark (from 5))))

;; Fetch only part of the article if we can.  I saw this in someone
;; else's .gnus
(setq gnus-read-active-file 'some)

;; Tree view for groups.  I like the organisational feel this has.
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

;; Threads!  I hate reading un-threaded email -- especially mailing
;; lists.  This helps a ton!
(setq gnus-summary-thread-gathering-function
      'gnus-gather-threads-by-subject)

;; Also, I prefer to see only the top level message.  If a message has
;; several replies or is part of a thread, only show the first
;; message.  'gnus-thread-ignore-subject' will ignore the subject and
;; look at 'In-Reply-To:' and 'References:' headers.
(setq gnus-thread-hide-subtree t)
(setq gnus-thread-ignore-subject t)

; Personal Information
(setq user-full-name "My Name"
      user-mail-address (if (my/at-office) "myname@office.com" "myname@mydomain.com")
      )

;; Change email address for work folder.  This is one of the most
;; interesting features of Gnus.  I plan on adding custom .sigs soon
;; for different mailing lists.
;; Usage, FROM: chen bin <work>
(setq gnus-posting-styles
      '((".*"
         (name "My Name"
          (address "myname@mydomain.com"
                   (organization "")
                   (signature-file "~/.signature")
                   ("X-Troll" "Emacs is better than Vi")
                   )))))


(setq mm-text-html-renderer 'w3m)

;; http://www.gnu.org/software/emacs/manual/html_node/gnus/_005b9_002e2_005d.html
(setq gnus-use-correct-string-widths nil)
;; @see http://emacs.1067599.n5.nabble.com/gnus-compile-td221680.html
;;(gnus-compile)
; =Gnus Tips=
;; @see http://www.scottmcpeak.com/gnus.html
;; }}