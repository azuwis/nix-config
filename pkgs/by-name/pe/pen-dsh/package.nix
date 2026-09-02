{
  stdenvNoCC,
  fetchFromGitHub,
  pen,
  deepseek-harness,
  writeScript,
  writeText,
  dshSkills ? {
    humanizer =
      let
        version = "2.11.1";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "blader";
        repo = "humanizer";
        tag = "v${version}";
        hash = "sha256-k6n1fZZV+42FIn7fVibqICwLM4VMQeouRpGk53FP7js=";
        nonConeMode = true;
        sparseCheckout = [ "/SKILL.md" ];
        postFetch = ''
          mkdir $out/humanizer
          mv $out/SKILL.md $out/humanizer/
        '';
      };
    ponytail =
      let
        version = "4.9.0";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "DietrichGebert";
        repo = "ponytail";
        tag = "v${version}";
        hash = "sha256-BwHCjJZBwMX1LBndaJNZmW9ywSv7LIlXZfjMlT27oGc=";
        rootDir = "skills";
      };
    superpowers =
      let
        version = "6.3.0";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "obra";
        repo = "superpowers";
        tag = "v${version}";
        hash = "sha256-d7ic7Sd8IvHj0QNelAzx2jGHVdjA1sYSYiW51+P6FYU=";
        rootDir = "skills";
      };
  },
}:

let
  skillsPatch = writeText "dsh-skills.patch.yml" (
    builtins.toJSON [
      {
        id = "skill-filesystem";
        disabled = false;
        config.customSkillDirs = builtins.attrValues dshSkills;
      }
    ]
  );
in

pen {
  name = "pen-dsh";
  agentPackage = deepseek-harness;
  agentWrapperArgs = [
    "--set"
    "DSH_PERMISSION_MODE"
    "danger-full-access"
    "--set"
    "DSH_TELEMETRY_DISABLED"
    "1"
    "--set"
    "NODE_USE_ENV_PROXY"
    "1"
    "--add-flags"
    "--patch ${skillsPatch}"
  ];
  allowWrite = [
    "."
    "~/.dsh"
  ];
  extraPassthru = {
    skillsUpdate = builtins.mapAttrs (
      name: skill:
      if skill ? src then
        skill
      else
        stdenvNoCC.mkDerivation {
          pname = "dsh-skill-${name}";
          version = skill.version or "0";
          src = skill;
        }
    ) dshSkills;
    updateScript = {
      command = writeScript "update-pen-dsh" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p gawk gitMinimal nix-update

        set -euo pipefail

        nix-update pen-dsh.skillsUpdate.humanizer >&2
        nix-update pen-dsh.skillsUpdate.ponytail >&2
        nix-update pen-dsh.skillsUpdate.superpowers >&2

        git diff HEAD | awk '
          /^ +[a-z][-a-z0-9]* =($| [^"])/   { name = $1 }
          /^-\s+version =/              { split($0, a, "\""); old = a[2] }
          /^\+\s+version =/ {
            split($0, a, "\"")
            if (old != a[2]) {
              if (msg) msg = msg ", "
              msg = msg name " " old " -> " a[2]
            }
          }
          END {
            if (!msg) print "[]"
            else printf "[{\"commitMessage\":\"pen-dsh: %s\"}]\n", msg
          }'
      '';
      supportedFeatures = [ "commit" ];
    };
  };
}
