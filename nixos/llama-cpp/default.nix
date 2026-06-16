{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.llama-cpp;
in

{
  options.services.llama-cpp = {
    enhance = lib.mkEnableOption "and enhance llama server";
  };

  config = lib.mkIf cfg.enhance {
    services.llama-cpp = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ll/llama-cpp/package.nix
      package = (pkgs.llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: {
        version = "9503";
        src = old.src.override {
          hash = "sha256-SnPK7hCfA7svxXhPji7Cuf7H8eHFjdTJSpNR1otPO4c=";
        };
        npmDepsHash = "sha256-1iM0LGeI9e+gZEHk46lkBe51DxIhiimfAm9o3Z3m9Ik=";
      });
      extraFlags = [
        # `models-max` does not work in modelsPreset."*"
        "--models-max"
        "1"
        # Server slots (n_parallel), per-model `parallel` overrides this.
        # Set here to suppress the misleading "n_parallel is set to auto/4"
        # at init, model-level values log later as `load: --parallel`.
        # Single user, save ~700MB VRAM (no extra KV cache slots)
        "--parallel"
        "1"
      ];
      modelsPreset = {
        "*" = {
          sleep-idle-seconds = "600";
        };
        # https://unsloth.ai/docs/models/qwen3.6
        # https://knightli.com/en/2026/05/26/rtx-3060-llama-cpp-n-cpu-moe-local-35b/
        "qwen3.6" = {
          alias = "qwen3.6";
          # download
          hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL"; # 22.4G
          # sampling
          temperature = "0.6";
          top-p = "0.95";
          top-k = "20";
          min-p = "0.00";
          jinja = true; # use embedded chat template
          reasoning-format = "deepseek"; # parse <think> tags
          # engine
          flash-attn = "on";
          n-gpu-layers = "99"; # all layers to GPU
          n-cpu-moe = "33"; # MoE experts on CPU (key for 12GB VRAM)
          # memory
          ctx-size = "262144"; # 256K
          cache-type-k = "q8_0"; # K cache must stay >= q8_0 for Qwen (q4_0 = catastrophic)
          cache-type-v = "q8_0"; # V cache can drop to q4_0 if VRAM tight (~0.3% PPL)
          no-context-shift = true; # stop at context limit instead of evicting old messages
          reasoning-budget = "16384"; # cap thinking tokens, 54t/s ~5min
          reasoning-budget-message = "... reasoning budget exceeded, answering now.";
          chat-template-kwargs = ''{"preserve_thinking": true}''; # keep reasoning across turns
        };
        # https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive
        "qwen3.6-hau" = {
          alias = "qwen3.6-hau";
          # download
          hf-repo = "HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:Q4_K_P"; # 23.4G
          # sampling
          temperature = "1.0";
          top-p = "0.95";
          top-k = "20";
          min-p = "0.00";
          jinja = true;
          reasoning-format = "deepseek";
          # engine
          flash-attn = "on";
          n-gpu-layers = "99";
          n-cpu-moe = "34";
          # memory
          ctx-size = "262144";
          cache-type-k = "q8_0";
          cache-type-v = "q8_0";
          no-context-shift = true;
          reasoning-budget = "16384";
          reasoning-budget-message = "... reasoning budget exceeded, answering now.";
          chat-template-kwargs = ''{"preserve_thinking": true}'';
        };
      };
    };
  };
}
