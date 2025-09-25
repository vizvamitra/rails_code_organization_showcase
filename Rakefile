# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :active_admin do
  desc "Build Active Admin Tailwind stylesheets"
  task build: :environment do
    command = [
      "tailwindcss",
      "-i", Rails.root.join("app/assets/stylesheets/active_admin.tailwind.css").to_s,
      "-o", Rails.root.join("app/assets/builds/active_admin.css").to_s,
      "-m"
    ]

    system(*command, exception: true)
  end

  desc "Watch Active Admin Tailwind stylesheets"
  task watch: :environment do
    command = [
      "tailwindcss",
      "--watch",
      "-i", Rails.root.join("app/assets/stylesheets/active_admin.tailwind.css").to_s,
      "-o", Rails.root.join("app/assets/builds/active_admin.css").to_s,
      "-m"
    ]

    system(*command)
  end
end

Rake::Task["assets:precompile"].enhance(["active_admin:build"])

Rake::Task["test:prepare"].enhance(["active_admin:build"]) if Rake::Task.task_defined?("test:prepare")
Rake::Task["spec:prepare"].enhance(["tailwindcss:build"]) if Rake::Task.task_defined?("spec:prepare")
Rake::Task["db:test:prepare"].enhance(["tailwindcss:build"]) if Rake::Task.task_defined?("db:test:prepare")
