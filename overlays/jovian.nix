final: prev: {
  # https://github.com/Jovian-Experiments/Jovian-NixOS/pull/376
  steam = prev.steam.override (old: {
    extraPkgs =
      pkgs: (if old ? extraPkgs then old.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
  });
}
