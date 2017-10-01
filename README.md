# SpeakEZ

2nd Place at HackHarvard

[_Devpost_](https://devpost.com/software/speak-ez/)

## Inspiration

Speak EZ was inspired by my Engineering, Innovation, and Design class, where we were given the task to design a phone system.  While thinking of ideas for the task, I thought that maybe an app to help you learn to speak better through speech analysis would be helpful.  So at HackHarvard, I decided to built this app.  While implementing the app, I was not sure which speech API would be best, so I decided I would build in the Google, Apple, and Microsoft APIs that I had access to for speech recognition, and allow for easy switching between the three.

## What it does

The app will talk to you by using AVSpeechUtterances, explaining all of the commands and functions as the user explores the app.  The user is then prompted with three speech modes, timed presentation, interview question, and freestyle.  Each speech mode is slightly different, where the timed presentation will give the user feedback on their current time, the interview question will pick a random question for the user to talk about, and freestyle just analyzes any speech.  In the analysis of speech, Speak EZ looks for:

Time/Length of Speech,
Filler words (ex. um, uh)
Sentiment Analysis word by word (Positive/Negative)
Common Word Choice
Word Complexity (Difficulty of words)

## How I built it

I built Speak EZ in XCode 8 with Swift 3.  It was made with the integration of Google, Apple, and Microsoft's speech APIs in order to give the user a choice of whichever API they like best.  The speech analysis is mostly done through Microsofts Cognitive Services APIs.

## Challenges I ran into

One of the biggest challenges I ran into is the detection of filler words.  Most speech APIs filter out filler words like um, as it is unlikely that people actually want to say them.  

## Accomplishments that I'm proud of

I am proud that I got all three speech APIs working as well as the sentiment and frequency analysis.

## What's next for Speak Ez

I will continue to work on it and if I am satisfied with the results, I would like to publish it.


If you would like to see more things that I (Avery Lamp) has made, check out my:

[_Devpost_](http://devpost.com/averylamp)

[_Website_](http://averylamp.me)

[_Youtube_](https://www.youtube.com/playlist?list=PLyC3kmCiJ2x31ZLjuB7RogEvyamrkSOo9)

If you would like to get in contact with me, here is my [_resume_](http://averylamp.me/Resume.pdf)
