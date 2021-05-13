# CheckHigh API

API to upload homework and check team's homework answer in sharing link

## Routes

All routes return Json

### Root
- GET `/`: Root route shows if Web API is running

#### Courses
- GET `api/v1/courses` : returns user's all courses
- POST `api/v1/courses/` : create a new course
- GET `api/v1/courses/[course_id]/assignments` : returns course's all assignments
- POST `api/v1/courses/[course_id]/assignments`

TODO:
- PUT `api/v1/courses/[course_id]` : update a course
- DELETE `api/v1/courses/[course_id]` : delete a course

#### ShareBoards
- GET `api/v1/shareboards` : returns user's all shareboards
- POST `api/v1/shareboards/` : create a new shareboards
- GET `api/v1/shareboards/[shareboard_id]` : returns shareboard's all assignments
- GET `api/v1/shareboards/[shareboard_id]/assignments`
- POST `api/v1/shareboards/[shareboard_id]/assignments`

TODO:
- PUT `api/v1/shareboards/[shareboard_id]` : update a shareboard
- DELETE `api/v1/shareboards/[shareboard_id]` : delete a shareboard

### Assignments
- GET `api/v1/assignments`: returns assignments which are not belongs to any course
- POST `api/v1/assignmets/`: upload a new assignment
- GET `api/v1/assignments/[assignmet_id]`: returns details about a single assignment with given ID

TODO:
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
