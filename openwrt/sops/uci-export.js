#!/usr/bin/ucode

import { cursor } from 'uci';

const uci = cursor();
const filter_pattern = (length(ARGV) > 0) ? regexp(ARGV[0]) : /.*/;

let output_tree = {};
for (let conf_name in uci.configs()) {
  let sections = uci.get_all(conf_name);
  for (let sect_name, data in sections) {
    let matched_opts = { ".type": data[".type"] };
    let has_match = false;

    for (let k, v in data) {
      if (match(k, /^\./)) continue;
      if (match(`${conf_name}.${sect_name}.${k}`, filter_pattern)) {
        matched_opts[k] = v;
        has_match = true;
      }
    }
    if (has_match) {
      if (!output_tree[conf_name]) output_tree[conf_name] = {};
      output_tree[conf_name][sect_name] = matched_opts;
    }
  }
}

printf("%.2J\n", output_tree);
