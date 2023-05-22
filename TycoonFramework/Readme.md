# Tycoon Framework

This directory contains stripped template code for managing a Tycoon's basic processes.
This framework has been configured for use in a single-Tycoon context, and a multi-Tycoon context.

## Code Organization
There are several key components encapsulated in ModuleScript metatables for managing tycoon processes.
A full diagram can be seen below:

A single Server Script **Driver** is used for server-side initialization of Tycoon functionality 
to setup each Tycoon.

### Staff
Each Tycoon has a set of "Staff" scripts specific to it. One instance of each staff member
is created per tycoon.

Staff scripts are essentially metatables created through a ModuleScript and maintained by the Organizer,
(for non-Organizer metatables), and the Driver (for Organizer metatables).

The role of each Staff member is described next.

#### Organizer
The Organizer is responsible for setting up a Tycoon by creating and initializing all other Staff
metatable Scripts. The Organizer maintains a reference to each created Staff member.

#### Broker
The Broker handles Tycoon income, revenue, and payment.

Tycoons generate a set amount of revenue every timestep based on the current income amount.
On request, the Broker will decrease from the current stored revenue for Player payment.
It is generally assumed that only the Owner of a Tycoon can receive payment,
but this can be adjusted as needed.

#### Vendor
The Vendor handles Tycoon Item purchasing. 

A Vendor maintains a Tycoon-specific ItemCatalog and verifies Player purchases on request 
based on lock conditions, and cost. The Vendor verifies purchases with the **Broker**, 
and passes approved requests to the **Builder**.

#### Builder
The Builder handles Tycoon Item building and removal.

This includes the movement of Item models, Temporary Models, and Purchase Buttons from ServerStorage
to workspace. More details about these components are in the Items section below.

#### Gatekeeper
The Gatekeeper handles Tycoon ownership.

The Gatekeeper controls when and who has owner permissions for a Tycoon and will pass this information
onto other Staff Scripts as needed. An event-based notification system facilitates updates to ownership.

#### Security
Security handles owner-access within a Tycoon.

Security controls owner-specific permissions within a Tycoon such as blocking non-owner players from
entering certain areas. This is an optional Staff member.

### External Access
Accessing Tycoon scripts from outside of the Tycoon's network is generally offered through the Organizer,
as it has immediate access to each Staff member.

This can be modified as needed, and a set of "public" methods for retrieving Tycoon data are available
in Staff scripts such as the **Vendor**, **Gatekeeper** and **Broker**.

## Tycoon Purchases
Tycoon purchases are described by an ItemCatalog. All Tycoons in a game can use the same **MasterCatalog**
to read item information such as cost, name, and prerequisites for creation.

A **Cataloger** ModuleScript is responsible for creating and distributing copies of an ItemCatalog
for safe modification of Items.

### Items
Items themselves are represented using small data tables of key-value pairs.
The only required value in a table is the cost of an item, as the key acts as a unique identifier.

The Vendor and Builder reference items by Id and use the Id to reference craftable Item Models.

By personal preference, I tend to keep the craftable Items for a Tycoon within sub-folders in workspace and
ServerStorage. These are directly referenced by the Organizer and Builder.

#### Item Structure
Asides from Cost, the base implementation for Items I use includes properties such as:

**Name**: A string identifier for referencing an Item and for use with GUI display.

**Prereq**: A table describing the other items that must be created first in-order to create
the item.

**Antireq**: A table describing the other items that cannot have been created prior to the item.

**Unlocks**: A table of Items Ids to which this item acts as a prerequistie.

**Blocks**: A table of Item Ids to which this Item acts as an antirequesite.
