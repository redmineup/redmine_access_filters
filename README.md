# Redmine Access filters plugin

This plugin allows you to deny web or REST API access from specific IP addresses for specific users and groups

## Requirements

* Redmine 2.3+
* Ruby 1.8.7, 1.9.3, 2.0.0

## Installation and Setup

* Follow the Redmine plugin installation steps at http://www.redmine.org/wiki/redmine/Plugins
* Restart your Redmine web servers (e.g. mongrel, thin, passenger)

## License

This plugin is licensed under the GNU GPL v2. See COPYRIGHT.txt and GPL.txt for details.

## Sponsorship

Pluing development was sponsored by MEDEVIT (http://www.medevit.at)

## Testing

Checkout a redmine version, clone this plugin under plugins/redmine_acess_filters
and run

    export RAILS_ENV=test
    bundle install
    bundle exec rake redmine:plugins NAME=redmine_access_filters
    bundle exec rake db:test:prepare
    bundle exec rake redmine:plugins:test
    # run a single test
    bundle exec ruby plugins/redmine_access_filters/test/functional/access_filter_test.rb  -n test_works_if_no_rules_exist

## github Actions

For unknown reason Niklaus was unable to make the github actions pass (August 21).
Running the tests locally worked fine, but on github I got always the error
messages containing `redirect to <http://test.host`. Have no idea, where and why
this redirection takes place.
