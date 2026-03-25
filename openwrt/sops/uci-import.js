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
      if (substr(sec_type, 0, 1) == "-") {
        uci.delete(conf, sect);
        sec_type = substr(sec_type, 1);
      }
      if (sec_type == "") {
        continue; // Section was just "-", skip processing options
      } else {
        uci.set(conf, sect, sec_type);
      }
    }

    for (let k, v in opts) {
      if (k == ".type") continue;

      if (v == "-") {
        uci.delete(conf, sect, k);
      } else if (substr(k, -1) == "+" && type(v) == "array") {
        let real_key = substr(k, 0, -1);
        let existing = uci.get(conf, sect, real_key);
        // Ensure 'existing' is treated as an array for the check
        let current_list = (type(existing) == "array") ? existing : (existing != null ? [existing] : []);
        for (let item in v) {
          if (!(item in current_list)) {
            uci.list_append(conf, sect, real_key, item);
          }
        }
      } else if (substr(k, -1) == "-" && type(v) == "array") {
        let real_key = substr(k, 0, -1);
        let existing = uci.get(conf, sect, real_key);
        let current_list = (type(existing) == "array") ? existing : (existing != null ? [existing] : []);
        for (let item in v) {
          if (item in current_list) {
            uci.list_remove(conf, sect, real_key, item);
          }
        }
      } else {
        uci.set(conf, sect, k, v);
      }
    }
  }
}

uci.save();
