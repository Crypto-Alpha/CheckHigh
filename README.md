# CheckHigh API

API to upload homework and check team's homework answer in sharing link

## Routes

All routes return Json

### Root
- GET `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts`: Create a new account

#### Courses
- GET `api/v1/courses` : returns user's all courses
- POST `api/v1/courses/` : create a new course
- GET `api/v1/courses/[course_id]/assignments` : returns course's all assignments
- POST `api/v1/courses/[course_id]/assignments`

TODO:
- PUT `api/v1/courses/[course_id]` : update a course
- DELETE `api/v1/courses/[course_id]` : delete a course

#### Share_Boards
- GET `api/v1/share_boards` : returns user's all share_boards
- POST `api/v1/share_boards/` : create a new share_boards
- GET `api/v1/share_boards/[share_board_id]` : returns share_board's information
- GET `api/v1/share_boards/[share_board_id]/assignments` : returns share_board's all assignments
- POST `api/v1/share_boards/[share_board_id]/assignments`

TODO:
- PUT `api/v1/share_boards/[share_board_id]` : update a share_board
- DELETE `api/v1/share_boards/[share_board_id]` : delete a share_board

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
