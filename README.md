# CheckHigh API

API to upload homework and check team's homework answer in sharing link

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/assignment/`: returns all confiugration IDs
- GET `api/v1/assignment/[ID]`: returns details about a single assignment with given ID
- POST `api/v1/assignmet/`: upload a new assignment

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```
