sample-endangered-pets
==============

This is a sample application designed to demonstrate how to use [Spreedly](https://spreedly.com) to collect money using credit cards and a variety of other payment methods.

You can see it running at [http://spreedly-endangered-pets.herokuapp.com](http://spreedly-endangered-pets.herokuapp.com/).

It uses the [httparty](https://github.com/jnunemaker/httparty) gem.

## Running

A free Spreedly [developer test account](https://id.spreedly.com/signup) is
required for this sample application to interact with the Spreedly API.

You need Postgres on your local system, either through [Postgres.app](http://postgresapp.com/),
or Homebrew (`brew install postgresql`).

To run:

```
$ git clone https://github.com/spreedly/sample-endangered-pets.git
$ cd sample-endangered-pets
$ bundle install
$ rake db:create
$ rake db:migrate
$ bundle exec rails server
```

Create a test environment in your account, and replace the keys in `env.rb` with
keys you generate there. Consult the [docs](https://docs.spreedly.com) to
learn how to generate API keys, access secrets, and gateway tokens.
