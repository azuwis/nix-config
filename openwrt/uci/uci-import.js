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
  let conf_path = `/etc/config/${conf}`;
  if (!fs.stat(conf_path))
    fs.writefile(conf_path, "");

  for (let sect, opts in sections) {
    let sec_type = opts[".type"];

    if (sec_type) {
      // ".type": "-" deletes the section
      if (sec_type == "-") {
        // For @type[N] references, only delete anonymous sections
        if (match(sect, /^@(.+)\[(\d+)\]$/)) {
          let section = uci.get_all(conf, sect);
          if (section && !section[".anonymous"])
            continue;
        }
        uci.delete(conf, sect);
        continue;
      }
      uci.set(conf, sect, sec_type);
    }

    for (let key, val in opts) {
      if (key == ".type") continue;
      let key_suffix = substr(key, -1);

      if (val == "-") {
        uci.delete(conf, sect, key);
      } else if ((key_suffix == "+" || key_suffix == "-") && type(val) == "array") {
        let real_key = substr(key, 0, -1);
        let existing = uci.get(conf, sect, real_key);
        if (type(existing) != "array") {
          existing = (existing != null) ? [existing] : [];
        }
        for (let item in val) {
          if (key_suffix == "+" && !(item in existing)) {
            uci.list_append(conf, sect, real_key, item);
          } else if (key_suffix == "-" && item in existing) {
            uci.list_remove(conf, sect, real_key, item);
          }
        }
      } else {
        let existing = uci.get(conf, sect, key);
        if (sprintf('%J', existing) != sprintf('%J', val)) {
          uci.set(conf, sect, key, val);
        }
      }
    }
  }
}

uci.save();
