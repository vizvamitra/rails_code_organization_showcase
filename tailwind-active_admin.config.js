const execSync = require("node:child_process").execSync;
const activeAdminPath = execSync("bundle show activeadmin", {
  encoding: "utf-8",
}).trim();

module.exports = {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    "./app/admin/**/*.{arb,erb,html,rb}",
    "./app/views/active_admin/**/*.{arb,erb,html,rb}",
    "./app/views/admin/**/*.{arb,erb,html,rb}",
    "./app/views/layouts/active_admin*.{erb,html}",
    "./app/assets/controllers/active_admin/**/*.js",
  ],
  darkMode: "selector",
};
