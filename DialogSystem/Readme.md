# Dialog Tree Framework
This directory contains images to describe a set of scripts responsible for managing Dialog Trees.

Dialog for this framework are assumed to be triggered through the use of ProximityPrompts

## Features
This framework was designed to support all of the following features for dialog trees.

### Tree-like Navigation
With the use of **Option** nodes and **Condition** nodes, dialog trees can branch out according to player decisions when encountering
nodes of dialog, and to the state of player or world data.

- Option nodes simply present two or more text-options that a user can select to influence dialog paths.
- Condition nodes are not visually represented and instead direct dialog according to player and world status.

Dialog Trees can be navigated forwards and backwards. There is custom styling defined and applied when viewing older nodes already displayed.

#### Viewing Old Nodes
Viewing previous nodes can cause problems with the presence of events and conditions.
Typically when viewing old dialog nodes, associated visual and audio cues will not duplicate for the Player.

Additionally, Players should be able to trace back to the first node regardless of which dialog branches they took to get to their current position.

As a result, the framework maintains the log of nodes already viewed, and uses indexing to maintain the Player's position within a stack of previous nodes.
Instead of popping nodes from the stack, indexing is used to offset from its head when navigating backwards.

Two variables are used for this process.
- **PrevNodeStack**: A table acting as a stack to hold previously visited Tree Nodes.
- **PrevNodeIdx**: An integer representing the deviation from the head node in a Dialog Tree.

The PrevNodeStack is updated when a new TreeNode associated with Dialog is read. Condition Nodes are omitted from the stack.
The stack is cleared if the Player moves past an Option node.

The PrevNodeIdx is updated when the player navigates to a previous node or to a subsequent node when viewing a previous node.

The process for updating the index in navigating the stack is outlined below.
![Navigating backwards](./Images/Framework/PrevNodeStack-Navigation.drawio.png?raw=true "Previous Node Stack")

### Styling Information
Dialog nodes can store styling properties to affect the appearance of text for display. Properties are interpreted by the **DialogSpeaker**.
Properties defined in this manner affect all of the text displayed within a node, such as supporting colouring for text, different fonts,
and text reading speeds.

More specific formatting for parts of text is supported using RichText features available on Roblox.
There is no inherent support for tokens to be replaced in this framework, but could be implemented in DialogSpeaker.

### Events and Conditions
Dialog events are simply function calls made affecting parts of the game. This can be used for superficial effects such as triggering audio cues and animations, or for making persistent changes
such as updating the player's inventory, or initiating a quest.

Dialog events are processed *before* dialog is read for a node. Dialog events that should take place after dialog is read are placed in a subsequent node.

Dialog condition nodes are used to direct dialog according to the status of the player or world. TreeNodes acting as condition nodes do not have associated dialog, and will evaluate to True or False
directing dialog accordingly.

### Example Tree
An example of a Dialog Tree comprising TreeNode information and DialogNode information is below.

![Dialog Tree Sample](./Images/Framework/Dialog-Tree-Sample.png?raw=true "Dialog Tree Sample")

## Code Organization
There are several scripts responsible for managing this system existing on the Server for validation and data storage,
and on the Client for presentation and styling.

### Client Scripts
The client scripts for this framework are suited to handle the presentation of dialog. this includes responsibilities such as formatting and decorating text, and populating the GUI elements for display.

There are four ModuleScripts responsible for handling this client-side functionality.

**ClientActuator**: Responsible for processing client-side dialog events and conditions. This is focused on events triggered through a dialog tree, as well as initiating and ending dialog reading.

**DialogReader**: Responsible for reading out dialog trees, processing each node as they are encountered.

**DialogSpeaker**: Responsible for displaying dialog text and nodes according to formatting instructions.

**ClientManuscript**: Responsible for retrieving and returning dialog tree information from the server.

### Server Scripts
The server scripts for this framework are suited to handle the storage of dialog trees, and processing of events pertaining to the server (for verification).

There are three ModuleScripts responsible for handling this server-side functionality.

**DialogActuator**: Responsible for processing server-side dialog events. Processing is requested by the client to verify event conditions.

**ManuscriptAccess**: Responsible for retrieving dialog information to pass to the client.

**Manuscript**: Responsible for maintaining dialog trees and node information. Verifies the integrity of dialog trees and nodes on server startup.

### All Together
A simplified entity diagram describing how these scripts interact is below. A more complete example can be found in the Images/Framework folder as "Framework-Scripts".

![Dialog Framework Entities](./Images/Framework/Framework-Entities.png?raw=true "Framework Entities")

More examples of the Dialog Tree in-action can be found in the [Demonstrations](./Images/Demonstrations) folder.
A small set of examples can also be viewed in action here: https://www.roblox.com/games/13547570018/Scripting-Experiments?AssetId=13547570018
