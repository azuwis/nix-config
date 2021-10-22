;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(setq doom-font (font-spec :family "JetBrains Mono" :size 15 :weight 'light))
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
