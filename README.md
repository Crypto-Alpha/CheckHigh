# CheckHigh API

API to upload homework and check team's homework answer in sharing link

## Routes

All routes return Json

### Root
- GET `/`: Root route shows if Web API is running

### Dashboards
- GET `api/v1/dashboards/[dashboard_id]` : returns users' dashboard

#### Courses
- GET `api/v1/courses` : returns user's all courses
- GET `api/v1/courses/[course_id]` : returns course's all assignments
- POST `api/v1/courses/` : create a new course
- PUT `api/v1/courses/[course_id]` : update a course
- DELETE `api/v1/courses/[course_id]` : delete a course

#### Sections
- GET `api/v1/sections` : returns user's all sections
- GET `api/v1/sections/[section_id]` : returns section's all assignments
- POST `api/v1/sections/` : create a new section
- PUT `api/v1/sections/[section_id]` : update a section
- DELETE `api/v1/sections/[section_id]` : delete a section

### Assignments
- GET `api/v1/assignments`: returns assignments which are not belongs to any course
- GET `api/v1/assignments/[assignmet_id]`: returns details about a single assignment with given ID
- POST `api/v1/assignmets/`: upload a new assignment
- PUT `api/v1/assignmets/[assignmet_id]` : update a assignmet
- DELETE `api/v1/assignmets/[assignmet_id]` : delete a assignmet

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
