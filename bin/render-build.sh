#!/bin/bash
set -e

bundle install
bundle exec rails assets:precompile
