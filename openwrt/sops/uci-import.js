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
    if (opts[".type"]) uci.set(conf, sect, opts[".type"]);

    for (let k, v in opts) {
      if (k == ".type") continue;
      uci.set(conf, sect, k, v);
    }
  }
}

uci.save()
