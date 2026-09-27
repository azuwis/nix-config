{ pen-dsh }:

(pen-dsh.override {
  enableOffice = true;
}).overrideAttrs
  (old: {
    passthru = old.passthru // {
      enable = false;
    };
  })
