# Tycoon Framework

## Overview
This repository defines a framework for managing all basic functionality needed to create
and run Tycoons as they traditionally appear in Roblox.

### Dependencies
The realized implementation of this project relies on the following external packages:
- Knit: https://github.com/Sleitnick/Knit by Sleitnick
- Component: https://github.com/Sleitnick/RbxUtil by Sleitnick



## Tycoon Structure
The core structure of the Tycoon Framework for server-representation is described here.
![Tycoon Structure Component Overview](./Images/Tycoon-Structure-Overview.png?raw=true "Tycoon Structure Component Overview")

### Workers
Major functionalities for the Tycoon are managed by independent 'TycoonWorker' ModuleScripts
that carry out a single core responsibility, described below.

**Broker**: Manages the Tycoon's finances to generate income and approve purchases using held revenue.

**Builder**: Creates models and instances tied to a Tycoon including purchases.

**Vendor**: Validates and finalizes purchase requests for a Tycoon.

**Cataloger**: Maintains a copy of the *TycoonPurchaseIndex*, with information defining 
purchase dependencies.

All of these Workers exist within a *PlayerTycoon* instance which represents all data 
tied to a Tycoon instance.


### Tycoon-Specific Data
Tycoon-specific data is represented in key-value lookup tables attached to a specific
TycoonWorker, or to the PlayerTycoon instance itself.

All data values support "OnChange" notifications to broadcast changed values through events.
Support for OnChange functionality is achieved through the table which is created as a
Subscribable table instance.

More info: LINK

#### Directory
To avoid coupling between Tycoon Workers and code outside of the PlayerTycoon, a 
TycoonDirectory Module is used to map DataKeys to the TycoonWorker holding the associated value.

More specifically, the mapping points to the TycoonWorker's subscribable data table.

The flow of data requests is visualized below:
![Subscribe Data Request Flow](./Images/Flow-Subscribe-to-Tycoon-Data.png?raw=true "A diagram showcasing the flow of tycoon subscription requests")

#### Why This Approach?
The Subscribable lookup data design is used to avoid defining specific data members within
TycoonWorker types supporting flexibility, and helping to catch data reference misses.

Data is subscribable to support an Observer pattern where listeners can asynchronously receive
data changes on the server and on the client.


### Non-Worker Instances
Any ModuleScripts acting as smart objects that need Tycoon data to function, are referred to as
TycoonObjects. A subset of these smart objects derive from the external Component type definition
and are known as TycoonComponents.

#### Data Flow
TycoonObjects are associated with a specific Tycoon through an assigned TycoonId attribute.
Each unique Tycoon instance in-game has a unique id that can be assigned randomly or pre-assigned.

In my own realized implementation, expected directory structure in ServerStorage is used to build
the association between TycoonObjects and a specific Tycoon instance.

At tycoon initialization time, the Builder assigns the TycoonId attribute to all TycoonObjects.


### Purchases
To maintain the order of Tycoon purchases, an optional hierarchical dependency tree can be defined
for each individual purchase. Dependencies support prerequisites and antirequisites, which can be
aggregated using boolean operator logic (AND, OR, XOR).

*XOR is only technically supported through the use of a combination of AND and OR operators with
prerequisites and antirequisites.

#### Structure
Each unique purchase in-game is represented by a single PurchaseNode table type, defined below:

```lua
type PurchaseNode = {
    PurchaseId: number,
    PurchaseName: string,
    Cost: number,
    Prerequisites: PurchaseDependencyNode,
    Antirequisites: PurchaseDependencyNode,
    Locks: {number},
    Unlocks: {number}
}
```
Prerequisites and antirequisites are defined prior to runtime.
Locks and unlocks are defined automatically at runtime.

#### PurchaseDependencyNode
PurchaseDependencyNodes are special table types with the type definition seen below:

```lua
type PurchaseDependencyNode = {
    DependencyIds: {PurchaseDependencyNode},
    DependencyRequiredNum: number,
    DependencyOperator: number
}
```

The DependencyIds link to PurchaseDependencyNodes for forming the tree-like structure.
The DependencyOperator (AND, OR) determines the DependencyRequiredNum for the node.

A Purchase is considered "unlocked" for purchase when the DependencyRequiredNum reaches 0.

##### Example
An example of a PurchaseDependencyNode tree is below.
![TycoonPurchaseIndex-Dependency-Example](./Images/TycoonPurchaseIndex-Dependency-Example.png?raw=true, "An example of a Dependency Tree for a specific purchase")

## Additional Topics
The implementation of other functionalities not specific to server-sided Tycoon functionality
is discussed in the topics below.

### Client-Server Communication
A pair of ModuleScripts are used to connect the server-scripts with the client-scripts for this
framework implementation:

**TycoonRequestService**: Defines an API for server code and the client to safely interact with
PlayerTycoon instances by making requests.

**TycoonRequestController**: Defines a client API for making requests to TycoonRequestService
and listening for data updates.

#### Naming Scheme
The naming scheme employed is based on that found for the Knit external library, which is the
chosen implementation for managing server-client communication.


### Player Data Representation
The implementation of PlayerData tied to a Tycoon is not officially defined, and designed to be
shaped according to what suits the project best.

*However*, in-order for Player Data to be used to interact with TycoonData values, 
PlayerData must be convertible into a table of {[key] = value} pairs matching data keys
defined in the PlayerTycoon.
