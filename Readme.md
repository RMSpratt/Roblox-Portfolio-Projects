# Roblox Project Portfolio
Below is a brief sampling of the projects included in this portfolio repository.

## Large Coding Projects
My larger Roblox projects mostly comprise personal projects for implementing frameworks and/or experimenting in Lua.

### Dialog-Tree Framework
This project saw the creation of a framework for managing dnd displaying Dialog Trees. 

This framework has support for:
- Navigating forwards and backwards
- Processing branches from options
- Triggering events for reaching nodes
- Evaluating conditions to determine flow of a tree
- Custom styling for dialog nodes

More details can be found in the [DialogSystem folder](./DialogSystem).

The code is not included, but a collection of sequence diagrams and entity models paint a picture of the framework.
I have personally used the framework for regular NPCs and facilitating quest dialog.

![Dialog-Options-Prompt](./DialogSystem/Images/Demonstrations/Dialog-Options-Prompt.png?raw=true "Dialog Node Preview")

### Tycoon Framework 
Implementation of a template reusable Tycoon Framework with support for the following features:
- Generating and managing Tycoon revenue for purchases
- Loading and unloading instances as Tycoon purchases
- Defining available purchases using saved purchase history and dependency trees
- Defining subscribable Tycoon data with low coupling for external actors and Tycoon functionality
- Communicating Tycoon data to individual clients
- Support for saved player data

More details can be found here: [Tycoon Framework](<./Tycoon Framework>)

## Small Coding Projects
I have also worked on creating a number of smaller coding projects.

These have not been directly applied to published games, but have been abstracted as templates for future possible use.

### Chat Filters
I created a set of custom chat filters to create "ghost chatrooms" that hide messages from a general chatroom. 
An example application for this code is for creating a Lobby chatroom that hides messages from players in an active round of gameplay.

### Global Leaderboard
I worked on creating global leaderboards capable of tracking different stats and updating in real time.
Updates are handled on the Server and passed to the client where they are animated for display.

An animated video can be found here: [Animated Leaderboard](./GlobalLeaderboard/Images-Video/Leaderboard-Update.gif).

![Sample leaderboard display](./GlobalLeaderboard/Images-Video/Leaderboard-Displays.png?raw=true "Global Leaderboard")

### Tool Re-working
I have re-created the functionality for several classic Roblox gear, restoring thier functionality using updated features
such as FilteringEnabled. Samples can be found [Here](./Tools).

![Decoy Deploy](./Tools/DecoyDeploy/Decoy-Deploy-Prev.png?raw=true "Decoy Deploy Preview")
![Snowball Cannon](./Tools/SnowballCannon/Snowball-Cannon-Prev.png?raw=true "Snowball Cannon Preview")
