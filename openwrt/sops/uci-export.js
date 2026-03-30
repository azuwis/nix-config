#!/usr/bin/ucode

import { cursor } from 'uci';

const uci = cursor();
const include_pattern = (length(ARGV) > 0) ? regexp(ARGV[0]) : /.*/;
const exclude_pattern = (length(ARGV) > 1) ? regexp(ARGV[1]) : /^$/;

let output_tree = {};
for (let conf_name in sort(uci.configs())) {
  let sections = uci.get_all(conf_name);

  // Track counts per section type for this specific config file
  let type_counters = {};

  for (let sect_name in sort(keys(sections))) {
    let data = sections[sect_name];
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
      let full_name = `${conf_name}.${display_name}.${k}`;
      if (match(full_name, include_pattern) && !match(full_name, exclude_pattern)) {
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
