# Elm Game Narrative Starter

 Elm game/narrative Engine and story starter
adds several extensions to the original Elm Narrative Engine by Jeff Schomay  :
[elm-interactive-story-starter](https://github.com/jschomay/elm-interactive-story-starter)
that were implemented by Nuno Torres


- The ability to pose questions to the player , and the ability for the player to answer those questions
Answers can be checked using just this Elm project or  making  requests to backend APIs

- The ability to add attributes to Interactables , like for instance counters that can be used
to track several different stuff , like for instance the number of times the player enters a location or interacts with another character ...

- the ability to get geoLocation information  , like for instance gps coordinates , and to associate
gps Zones ( circles centered on a given gps coords point with a given radius ) to Locations
and require ( if so desired , its not mandatory ) that the player be located in a given gps Zone
before being allowed to enter a game/narrative location

- support for Several Languages : besides allowing the narrative to reach a greater audience ,
There's almost always several versions/narratives/points of view
around one Single Truth ...

- several tests to prevent  creating Rules that try to create interactions with non-existent interactables ( characters , items , locations )

- the ability to save/load the interaction history list to Local Storage



# Interactive Story Starter

just like the original Elm Narrative Engine , this project can be (re)used to start your own project.
You just have to rewrite the configuration files in the OurStory folder , mainly   Narrative.elm , NarrativeDataStructures.elm  , Manifest.elm and maybe Rules.elm ( also maybe NarrativeEnglish.elm , etc ,  if you want support for more than one language )


# The example
One example game/narrative ( ourStory  ) was created
to exemplify how you can use this project to create your own game/narrative


-  __ourStory__ : presents 10 stages each with some questions or options  about it ...


# Update to Elm 0.19
the update went without any major troubles , the biggest challenge was finding  an alternative to the geolocation package that is not yet  updated to Elm 0.19 ( I decided to use ports and write a js function in index.html that requests the geolocation info ... )


besides updating ,  some code refactoring in the OurStory folder was done that makes it a bit more clear ( I think )
and some new features were also introduced like the Goals Status Report . If players are required to
answer all stage questions before proceeding to the next stage that's not so important , but if they
can move without answering all questions it becomes important so that when they reach the end they know
to which points they have to return to complete the requirements and  finish the game ...


Enjoy playing the  guided tour/questionnaire ( proof of concept ) example at
[Guided Tour through Vila Sassetti - Sintra](https://sintraubuntuer.github.io/pages/guided-tour-through-vila-sassetti-sintra.html){:target="_blank"}
and enjoy creating your interactive story!
