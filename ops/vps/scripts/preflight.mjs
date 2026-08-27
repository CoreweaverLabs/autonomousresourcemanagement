import { existsSync, readFileSync, statSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(process.cwd());
const requiredFiles = ["index.html", "robots.txt", "sitemap.xml", "llms.txt", "schema.json"];
const errors = [];

for (const file of requiredFiles) {
  const path = resolve(root, file);
  if (!existsSync(path) || !statSync(path).isFile()) {
    errors.push(`Missing required static artifact: ${file}`);
  }
}

if (errors.length === 0) {
  const index = readFileSync(resolve(root, "index.html"), "utf8");
  const robots = readFileSync(resolve(root, "robots.txt"), "utf8");
  const sitemap = readFileSync(resolve(root, "sitemap.xml"), "utf8");
  const schema = readFileSync(resolve(root, "schema.json"), "utf8");

  if (!index.includes('application/ld+json')) errors.push("index.html has no inline JSON-LD block");
  if (!robots.match(/^Sitemap:\s*https?:\/\//im)) errors.push("robots.txt has no absolute Sitemap directive");
  if (!sitemap.includes("<urlset")) errors.push("sitemap.xml does not contain a URL set");
  if (!schema.includes('"@context"')) errors.push("schema.json does not contain JSON-LD context");
  if (index.includes("__ARM_HOSTNAME__") || index.includes("REPLACE_ME")) {
    errors.push("index.html still contains a release placeholder");
  }
}

if (errors.length > 0) {
  console.error("VPS page-factory preflight failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`VPS page-factory preflight passed for ${root}`);
