final: prev: {
  # Fix `error: unused option: HYPERV`, remove after nixos-25.11 release
  linux_jovian = prev.linux_jovian.override {
    argsOverride.structuredExtraConfig =
      let
        inputs = import ../inputs;
        prevArgs = (
          final.callPackage "${inputs.jovian-nixos.outPath}/pkgs/linux-jovian" { buildLinux = x: x; }
        );
      in
      prevArgs.structuredExtraConfig
      // {
        HYPERV = final.lib.mkForce (final.lib.kernel.option final.lib.kernel.no);
      };
  };

  # https://github.com/Jovian-Experiments/Jovian-NixOS/pull/376
  steam = prev.steam.override (old: {
    extraPkgs =
      pkgs: (if old ? extraPkgs then old.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
  });
}
