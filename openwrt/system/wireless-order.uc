#!/usr/bin/ucode
import { cursor } from "uci";

const uci = cursor();
let radios = [];
uci.foreach("wireless", "wifi-device", (s) => {
	let m = match(s[".name"], /^radio(\d+)$/);
	if (m)
		push(radios, { idx: +m[1], band: s.band });
});

let sorted = sort([...radios], (a, b) =>
	(a.band > b.band) - (a.band < b.band) || a.idx - b.idx);

if (length(filter(sorted, (r, i) => r.idx != i)) == 0)
	exit(0);

for (let r in radios) {
	uci.rename("wireless", `radio${r.idx}`, `_radio${r.idx}`);
	if (uci.get("wireless", `default_radio${r.idx}`))
		uci.rename("wireless", `default_radio${r.idx}`, `_default_radio${r.idx}`);
}

for (let i = 0; i < length(sorted); i++) {
	uci.rename("wireless", `_radio${sorted[i].idx}`, `radio${i}`);
	if (uci.get("wireless", `_default_radio${sorted[i].idx}`)) {
		uci.set("wireless", `_default_radio${sorted[i].idx}`, "device", `radio${i}`);
		uci.rename("wireless", `_default_radio${sorted[i].idx}`, `default_radio${i}`);
	}
}

uci.commit("wireless");
