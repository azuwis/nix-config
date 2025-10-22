#!/usr/bin/env nix-shell
/*
#!nix-shell -p nodejs -p terser -i node
*/

const { minify } = require("terser");
const fs = require("fs");
const path = require("path");

async function processFiles() {
  const dir = __dirname;
  const files = fs.readdirSync(dir);
  const jsFiles = files.filter(f => f.endsWith(".js") && f !== path.basename(__filename));
  
  const result = [];

  for (const file of jsFiles) {
    const filePath = path.join(dir, file);
    const code = fs.readFileSync(filePath, "utf8");
    
    try {
      const minified = await minify(code, {
        enclose: true
      });

      const bookmarkletCode = `javascript:${minified.code}`;
      const title = path.basename(file, ".js");

      result.push({
        Title: title,
        URL: bookmarkletCode,
        Placement: "menu"
      });

    } catch (err) {
      console.error(`Error processing ${file}:`, err);
    }
  }

  fs.writeFileSync(path.join(__dirname, "bookmarklets.json"), JSON.stringify(result, null, 2));
  console.log("Bookmarklets JSON created");
}

processFiles();
