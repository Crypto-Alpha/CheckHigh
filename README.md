# CheckHigh API

API to upload homework assignments and check team's homework answers in your own share boards!

## Status
[![Ruby v3.0.1](https://img.shields.io/badge/Ruby-3.0.1-green)](https://www.ruby-lang.org/en/news/2021/04/05/ruby-3-0-1-released/)

## [Website Usage](https://checkhigh-api.herokuapp.com)

## Routes

Almost all of the routes return Json, except for `api/v1/assignments/[assignmet_id]/assignment_content` returns **PDF binary codes in text/plain string format**

### Root
- GET `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts`: Create a new account

#### Courses
- GET `api/v1/courses` : returns user's all courses
- POST `api/v1/courses` : create a new course
- GET `api/v1/courses/[course_id]`: return a specific course info
- PUT `api/v1/courses/[course_id]` : update a course (for now supports renaming course feature)
- DELETE `api/v1/courses/[course_id]` : delete a course
##### Course assignments related
- GET `api/v1/courses/[course_id]/assignments` : returns course's all assignments
- POST `api/v1/courses/[course_id]/assignments`: create new assignments into a specific course
- PUT `api/v1/courses/[course_id]/assignments/[assignment_id]`: move an assignment into a course
- DELETE `api/v1/courses/[course_id]/assignments/[assignment_id]`: remove an assignment from a course

#### Share Boards
- GET `api/v1/share_boards` : returns user's all shareboards
- POST `api/v1/share_boards` : create a new shareboard
- GET `api/v1/share_boards/[share_board_id]` : returns a specific shareboard's info
- PUT `api/v1/share_boards/[share_board_id]` : update a shareboard (for now supports renaming shareboard feature)
- DELETE `api/v1/share_boards/[share_board_id]` : delete a shareboard
##### Share Board assignments related
- GET `api/v1/share_boards/[share_board_id]/assignments` : returns shareboard's all assignments
- POST `api/v1/share_boards/[share_board_id]/assignments` : create new assignments into a specific shareboard 
- POST `api/v1/share_boards/[share_board_id]/assignments/[assignment_id]` : move an assignment into a shareboard 
- DELETE `api/v1/share_boards/[share_board_id]/assignments/[assignment_id]`: remove an assignment from a shareboard
##### Share Board collaborators related
- POST `api/v1/share_boards/[share_board_id]/collaborators`: send invitation links to who didn't register checkhigh yet to register as a collaborator 
- PUT `api/v1/share_boards/[share_board_id]/collaborators`: add a new user as a collaborator to a shareboard  
- DELETE `api/v1/share_boards/[share_board_id]/collaborators`: remove a new user as a collaborator to a shareboard  


#### Assignments
- GET `api/v1/assignments`: returns assignments which are not belong to any course
- POST `api/v1/assignmets`: upload a new assignment
- GET `api/v1/assignments/[assignmet_id]`: returns assignment infos about a single assignment with given ID
- GET `api/v1/assignments/[assignmet_id]/assignment_content`: returns assignment content about a single assignment with given ID (now storing PDF binary codes encrypted)
- PUT `api/v1/assignmets/[assignmet_id]` : update an assignment (for now supports renaming assignment name features)
- DELETE `api/v1/assignmets/[assignmet_id]` : delete an assignment

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
rake spec
```

## Execute

Run this API using:

```shell
rake run:dev
```

## License
* 2021, Rona Lu-Lai 呂賴臻柔
* 2021, Riley Kao 高靖雅
* 2021, Yan-Yu Fu 傅嬿羽
