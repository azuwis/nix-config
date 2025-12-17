{
  target,
}:

if target == "" then
  import ./lock.nix { pure = false; }
else
  (import ./lock.lock) // { ${target} = (import ./lock.nix { pure = false; }).${target}; }
