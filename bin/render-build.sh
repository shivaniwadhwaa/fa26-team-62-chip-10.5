#!/usr/bin/env bash
# Build script Render runs on every deploy.
set -o errexit

bundle install
npm install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare
