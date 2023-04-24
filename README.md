
# iPhone Lessons

Show Lessons from iPhone Photography on TableView with model LessonFeed with following structure:


## LessonFeed

 - id: Int
 - name: String
 - description: String
 - thumnail: URL
 - video_url: URL

 ## Story: Customer requests to see their iPhone Photography Lessons

 ## Pointer #1:
 ```
If a user has a working internet connection, 
they want the app to go to the internet in the background
and fetch latest lessons from the server without any UI freeze
```

### As a developer, we want to follow the given flow chart to achieve this:
![Alt text](/Images/LessonLoader.png "LessonLoader Overview")

## Flow chart for App:
![Alt text](/Images/AppFlow.png "App Flow chart")

## Pointer #2:

```
If a user doesn't have a working internet connection,
and they open the app and requests to see lessons feed,
the app should check for a cached version of the lessons.
If a cached version of the lessons is available, 
display that cache to the user.
```
```
Given there is no internet connectivty and the 
cache either doesn't exist or has expired, 
display appropriate error message to the user. 
```
