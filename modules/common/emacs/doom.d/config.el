;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; fullscreen and undecorated on macOS
(if (eq system-type 'darwin)
    (progn
      (defun toggle-frame-fullscreen ()
        (interactive)
        (let* ((frame (selected-frame))
               (on? (and (frame-parameter frame 'undecorated)
                         (eq (frame-parameter frame 'fullscreen) 'maximized)))
               (geom (frame-monitor-attribute 'geometry))
               (x (nth 0 geom))
               (y (+ (nth 1 geom) 24))
               (display-height (nth 3 geom))
               (display-width (nth 2 geom))
               (ns-menu-autohide (bound-and-true-p ns-auto-hide-menu-bar))
               (cut (if on?
                        (if ns-menu-autohide 26 50)
                      (if ns-menu-autohide 4 26)))
               (header-h (+ (tab-bar-height nil t) cut)))
          (set-frame-position frame x y)
          (set-frame-parameter frame 'fullscreen-restore 'maximized)
          (set-frame-parameter nil 'fullscreen 'maximized)
          (set-frame-parameter frame 'undecorated (not on?))
          (set-frame-height frame (- display-height header-h) nil t)
          (set-frame-width frame (- display-width 12) nil t)
          (set-frame-position frame x y)))
      (run-at-time "1 sec" nil #'toggle-frame-fullscreen)
      ))

(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15 :weight 'light))
(setq doom-unicode-font (font-spec :family "SF Pro" :size 15 :weight 'light))
(setq doom-theme 'doom-nord)
(setq projectile-project-search-path '("~/src/"))
(setq which-key-idle-delay 0.3)
(add-to-list 'auto-mode-alist '("\\.svelte\\'" . web-mode))
(after! web-mode
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0))
(after! javascript
  (setq js2-basic-offset 2))
