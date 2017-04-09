# README

## Heroku deployment

We used this custom buildpack to deploy to Heroku https://github.com/aarongray/heroku-buildpack-ruby

```
heroku buildpacks:set https://github.com/aarongray/heroku-buildpack-ruby
```

Therefore we need to set 2 config vars on Heroku:

```
APP_SUBDIR="backend"
BUNDLE_GEMFILE="backend/Gemfile"
```
