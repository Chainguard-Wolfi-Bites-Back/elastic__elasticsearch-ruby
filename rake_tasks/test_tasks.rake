# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

UNIT_TESTED_PROJECTS = [
  'elasticsearch',
  'elasticsearch-transport',
  'elasticsearch-dsl',
  'elasticsearch-api',
  'elasticsearch-xpack'
].freeze

INTEGRATION_TESTED_PROJECTS = (UNIT_TESTED_PROJECTS - ['elasticsearch-api']).freeze

namespace :test do
  task bundle: 'bundle:install'

  desc 'Run all tests in all subprojects'
  task client: [:unit, :integration]

  desc 'Run unit tests in all subprojects'
  task :unit do
    UNIT_TESTED_PROJECTS.each do |project|
      puts '-' * 80
      sh "cd #{CURRENT_PATH.join(project)} && unset BUNDLE_GEMFILE && unset BUNDLE_PATH && unset BUNDLE_BIN && bundle exec rake test:unit"
      puts "\n"
    end
  end

  desc 'Run integration tests in all subprojects'
  task :integration do
    INTEGRATION_TESTED_PROJECTS.each do |project|
      puts '-' * 80
      sh "cd #{CURRENT_PATH.join(project)} && unset BUNDLE_GEMFILE && bundle exec rake test:integration"
      puts "\n"
    end
  end

  desc 'Run rest api tests'
  task rest_api: ['elasticsearch:wait_for_green'] do
    puts '-' * 80
    sh "cd #{CURRENT_PATH.join('elasticsearch-api')} && unset BUNDLE_GEMFILE && bundle exec rake test:rest_api[true]"
    puts "\n"
  end

  desc 'Run security (Platinum) rest api yaml tests'
  task security: 'elasticsearch:update' do
    Rake::Task['elasticsearch:wait_for_green'].invoke
    Rake::Task['elasticsearch:checkout_build'].invoke
    puts '-' * 80
    sh "cd #{CURRENT_PATH.join('elasticsearch-xpack')} && unset BUNDLE_GEMFILE && bundle exec rake test:rest_api"
    puts "\n"
  end
end
