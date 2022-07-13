# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

Rails.application.load_tasks

Rake::Task['spec'].clear

RSpec::Core::RakeTask.new(:spec)

task ci: ['db:migrate', 'ci:setup:rspec', 'spec']
