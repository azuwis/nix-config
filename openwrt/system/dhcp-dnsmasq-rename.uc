#!/usr/bin/ucode
import { cursor } from "uci";
const uci = cursor();
for (let name, s in uci.get_all("dhcp")) {
	if (s[".type"] == "dnsmasq" && s[".anonymous"]) {
		uci.rename("dhcp", name, "main");
		uci.commit("dhcp");
		break;
	}
}
