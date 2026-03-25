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
      // ".type": "-type_name" deletes the existing section and recreates it as type "type_name"
      // ".type": "-" deletes the section without recreating
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
        if (type(existing) == "array") {
          for (let item in v) {
            if (!(item in existing)) {
              uci.list_append(conf, sect, real_key, item);
            }
          }
        } else {
          for (let item in v) {
            if (item != existing) {
              uci.list_append(conf, sect, real_key, item);
            }
          }
        }
      } else if (substr(k, -1) == "-" && type(v) == "array") {
        let real_key = substr(k, 0, -1);
        let existing = uci.get(conf, sect, real_key);
        if (type(existing) == "array") {
          for (let item in v) {
            if (item in existing) {
              uci.list_remove(conf, sect, real_key, item);
            }
          }
        }
      } else {
        let existing = uci.get(conf, sect, k);
        let changed = false;

        if (type(v) == "array") {
          if (type(existing) != "array") {
            changed = true;
          } else if (length(v) != length(existing)) {
            changed = true;
          } else {
            for (let i = 0; i < length(v); i++) {
              if (v[i] != existing[i]) {
                changed = true;
                break;
              }
            }
          }
        } else {
          if (existing != v) changed = true;
        }

        if (changed) {
          uci.set(conf, sect, k, v);
        }
      }
    }
  }
}

uci.save();
