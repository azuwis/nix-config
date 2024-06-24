self: super: {
  # https://github.com/Jovian-Experiments/Jovian-NixOS/pull/376
  steamPackages = super.steamPackages.overrideScope (
    _: scopeSuper: {
      steam-fhsenv = scopeSuper.steam-fhsenv.override (prev: {
        extraPkgs =
          pkgs: (if prev ? extraPkgs then prev.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
      });
    }
  );

  # Workaround for vimPlugins.* not in jovia/nixpkgs yet.
  # Remove it when jovian upgrades next time.
  # vimPlugins = super.vimPlugins // {
  #   neogit = self.vimUtils.buildVimPlugin {
  #     pname = "neogit";
  #     version = "2024-05-26";
  #     src = self.fetchFromGitHub {
  #       owner = "NeogitOrg";
  #       repo = "neogit";
  #       rev = "70ad95be902ee69b56410a5cfc690dd03104edb3";
  #       sha256 = "sha256-hkb33SOJJMqPXj8xJ1epZBDyH/OCX+MQom8jVPJEXyw=";
  #     };
  #     meta.homepage = "https://github.com/NeogitOrg/neogit/";
  #   };
  # };
}
