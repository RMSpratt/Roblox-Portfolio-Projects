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

### Styling Information
Dialog nodes can store styling properties to affect the appearance of text for display. Properties are interpreted by the **DialogSpeaker**.

### Events and Conditions

### Example Tree

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
