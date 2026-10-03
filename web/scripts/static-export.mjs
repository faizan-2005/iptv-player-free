import { access, rename } from "fs/promises";
import { spawnSync } from "child_process";

const api = new URL("../app/api", import.meta.url);
const bak = new URL("../app.api.bak", import.meta.url);

let moved = false;
try {
  await access(api);
  await rename(api, bak);
  moved = true;
} catch {}

const build = spawnSync("npx", ["next", "build"], {
  stdio: "inherit",
  shell: true,
  env: { ...process.env, STATIC_EXPORT: "1", NEXT_PUBLIC_STATIC_EXPORT: "1" }
});

if (moved) {
  try {
    await rename(bak, api);
  } catch {}
}

process.exit(build.status ?? 1);
