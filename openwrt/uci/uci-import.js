#!/usr/bin/ucode

import { cursor } from 'uci';
import * as fs from 'fs';

const uci = cursor();
let data = json(fs.stdin);

if (!data) {
  warn("No valid JSON data received\n");
  exit(1);
}

for (let conf, sections in data) {
  for (let sect, opts in sections) {
    let sec_type = opts[".type"];

    if (sec_type) {
      // ".type": "-" deletes the section
      if (sec_type == "-") {
        // For @type[N] references, only delete anonymous sections
        if (match(sect, /^@(.+)\[(\d+)\]$/)) {
          let s = uci.get_all(conf, sect);
          if (s && !s[".anonymous"])
            continue;
        }
        uci.delete(conf, sect);
        continue;
      }
      uci.set(conf, sect, sec_type);
    }

    for (let k, v in opts) {
      if (k == ".type") continue;
      let k_suffix = substr(k, -1);

      if (v == "-") {
        uci.delete(conf, sect, k);
      } else if ((k_suffix == "+" || k_suffix == "-") && type(v) == "array") {
        let real_key = substr(k, 0, -1);
        let existing = uci.get(conf, sect, real_key);
        if (type(existing) != "array") {
          existing = (existing != null) ? [existing] : [];
        }
        for (let item in v) {
          if (k_suffix == "+" && !(item in existing)) {
            uci.list_append(conf, sect, real_key, item);
          } else if (k_suffix == "-" && item in existing) {
            uci.list_remove(conf, sect, real_key, item);
          }
        }
      } else {
        let existing = uci.get(conf, sect, k);
        if (sprintf('%J', existing) != sprintf('%J', v)) {
          uci.set(conf, sect, k, v);
        }
      }
    }
  }
}

uci.save();
