#!/usr/bin/ucode

import { cursor } from 'uci';

const uci = cursor();
const filter_pattern = (length(ARGV) > 0) ? regexp(ARGV[0]) : /.*/;

let output_tree = {};
for (let conf_name in sort(uci.configs())) {
  let sections = uci.get_all(conf_name);

  // Track counts per section type for this specific config file
  let type_counters = {};

  for (let sect_name, data in sections) {
    let stype = data[".type"];

    // Increment counter for this type
    if (type_counters[stype] == null) type_counters[stype] = 0;
    else type_counters[stype]++;

    // Standard UCI notation uses @type[i] for anonymous sections
    let display_name = (data[".anonymous"])
      ? `@${stype}[${type_counters[stype]}]`
      : sect_name;

    let matched_opts = { ".type": stype };
    let has_match = false;

    for (let k in sort(keys(data))) {
      if (match(k, /^\./)) continue;
      let v = data[k];
      if (match(`${conf_name}.${display_name}.${k}`, filter_pattern)) {
        matched_opts[k] = v;
        has_match = true;
      }
    }

    if (has_match) {
      if (!output_tree[conf_name]) output_tree[conf_name] = {};
      output_tree[conf_name][display_name] = matched_opts;
    }
  }
}

printf("%.2J\n", output_tree);
