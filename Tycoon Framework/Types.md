# Type Previews

## Utility Types
```lua
--Defines any Type with a custom '_Type' attribute for validation and testing.
type CT = {
    _Type: string
}
```

## Subscribable Types
```lua

--Defines a table type with data that can be subscribed to for OnChange events.
type Subscribable = typeof(setmetatable({} :: {
    _Type: string,
    Data: {[string]: any},
    DataKeys: {[string]: string},
    DataEvents: {[string]: BindableEvent},
    Subscribers: {[string]: {
        Connections: {[string | Instance]: RBXScriptConnection},
        Num: number
    }},
}, {} :: SubscribableFuncs))

--Defines functions attached to Susbcribable type objects.
type SubscribableFuncs = {
    __index: SubscribableFuncs,
    AddDataKeyValuePair: (self: Subscribable, dataKey: string, dataValue: any) -> (boolean, string),
    AddAllDataKeyValuePairs: (self: Subscribable, dataKeyValuePairs: {[string]: any}) -> (boolean, string),
    ClearSubscribers: (self: Subscribable) -> (),
    Notify: SubscribableNotifyCB,
    Subscribe: (self: Subscribable, subscriberId: string | Instance, dataKey: string, updateCB: (string, any) -> ()) -> (boolean, string),
    Unsubscribe: (self: Subscribable, subscriberId: string | Instance, dataKey: string) -> (boolean, string)
}

--Defines the expected function callback signature for subscribers to Subscribable data.
type SubscribableNotifyCB = (subscribable: Subscribable, dataKey: string, dataValue: any, {}) -> ()
```

## Tycoon Types
The collection of types that rely on data of or represent data for PlayerTycoon instances.

### Tycoon Objects
A set of non-worker Tycoon instances that rely on PlayerTycoonData.

```lua
--Defines a non-TycoonWorker instance with specific functionality while a Tycoon is active.
type TycoonObject = {
    Instance: Instance,
    IsActive: boolean,
    RequestStarted: boolean,
    RequestStopped: boolean,
    TycoonId: number,
    TycoonIdAttribChanged: RBXScriptConnection,
    Activate: (self: TycoonObject) -> (),
    Deactivate: (self: TycoonObject) -> (),
} & UtilityTypes.CT

--Defines a fusion type of sleitnick's Component class with TycoonObject instances.
--See more: 
type TycoonComponent = typeof(Component.new(...)) & TycoonObject

--Defines an Instance that is purchased for a specific PlayerTycoon.
--Uniquely identified and tied to a defined instance within TycoonPurchaseIndex.
type TycoonPurchase = {
    TycoonId: number,   --Attached to specific PlayerTycoon
    PurchaseId: number, --Unique identifier within TycoonPurchaseIndex
    Instance: Instance,
} & UtilityTypes.CT
```


### Tycoon Directory
The TycoonDirectory class instance provides a lookup for PlayerTycoonData defined in TycoonWorkers.

```lua
--Defines the data for the TycoonDirectory table instance.
type TycoonDirectory = typeof(setmetatable(
    {} :: {
            _Type: string,
            DataLookupMap: {[string]: UtilityTypes.Subscribable},
            DataAccessMap: {[string]: number}
        },
    {} :: TycoonDirectoryFuncs
))

--Defines the functions found within the TycoonDirectory table instance.
type TycoonDirectoryFuncs = {
    __index: TycoonDirectoryFuncs,
    AddKeyToLookup: (self: TycoonDirectory, dataKey: string, workerData: UtilityTypes.Subscribable, accessLevel: number) -> (),
    GetAccessLevelForKey: (self: TycoonDirectory, dataKey: string) -> (),
    RemoveKeyFromLookup: (self: TycoonDirectory, dataKey: string) -> (),
    Clear: (self: TycoonDirectory) -> (),
}
```


### Player Tycoon
```lua

--Defines a PlayerTycoon with all associated data and workers.
type PlayerTycoon<T> = {
    Broker: TycoonTypesMod.Broker,
    Builder: TycoonTypesMod.Builder,
    Directory: TycoonTypesMod.TycoonDirectory,
    GlobalData: UtilityTypesMod.Subscribable,
    Owner: Player | nil,
    OwnerData: {[string]: any}?,
    OwnerId: number | nil,
    StartProps: {any}?,
    StartRequested: boolean,
    StopProps: {any}?,
    StopRequested: boolean,
    Vendor: TycoonTypesMod.Vendor,
}
```

### Tycoon Workers
The set of ModuleScripts to handle core functionality for managing a PlayerTycoon.

```lua
--Defines the Base Class for TycoonWorker instances.
--Generic Type parameters are used to support specific TycoonWorker type inference
--within generic functions, Initialize, Start, and Stop.
type TycoonWorker<T> = {
    IsActive: boolean,
    WorkerSubscribable: UtilityTypes.Subscribable,
    Initialize: (self: T, directory: TycoonDirectory, ...any) -> (),
    Start: (self: T, ...any) -> (),
    Stop: (self: T, ...any) -> (),
}

--Defines the Broker TycoonWorker functionality.
type Broker = {
    GenerateIncomeTask: any,
    ProcessPurchaseReceipt: (self: Broker, purchaseCost: number) -> boolean,
    ProcessPurchaseReturn: (self: Broker, purchaseId: number) -> (),
} & TycoonWorker<Broker>

--Defines the Builder TycoonWorker functionality.
type Builder = {
    ComponentPlotInitFolder: Instance?,
    ComponentPlotStartFolder: Instance?,
    ComponentStorageFolder: Instance?,
    PurchasePlotFolder: Instance?,
    PurchaseStorageFolder: Instance?,
    MoveInstanceToPlot: (self: Builder, Instance) -> (),
    MoveInstanceToStorage: (self: Builder, Instance) -> (),
} & TycoonWorker<Builder>

--Defines the Vendor TycoonWorker functionality.
type Vendor = {
    ButtonPlotFolder: Instance?,
    ButtonStorageFolder: Instance?,
    Cataloger: Cataloger,
    PurchaseButtons: {[number]: Instance},
    Purchase: (self: Vendor, broker: Broker, builder: Builder, purchaseBtn: Instance) -> (boolean, number?),
    ReturnPurchase: (self: Vendor, broker: Broker, builder: Builder, purchaseBtn: Instance) -> boolean,
} & TycoonWorker<Vendor>
```

### TycoonPurchaseIndex
There are two types defined for data held within the TycoonPurchaseIndex.

```lua
--Defines a unique purchase for any PlayerTycoon.
--Unique identifier is 'PurchaseId' which is also used as the key mapping to this object.
type PurchaseIndexNode = {
    Cost: number,
    Name: string,
    PurchaseId: number,
    Locks: {number}?
    Unlocks: {number}?,
    Antirequisites: PurchaseIndexDependencyNode?,
    Prerequisites: PurchaseIndexDependencyNode?,
}

--Describes a set of dependencies for unlocking a TycoonPurchase.
type PurchaseIndexDependencyNode = {
    Ids: {number | PurchaseIndexDependencyNode},
    Num: number?,
    Op: number,
}
```

### Cataloger
A non-TycoonWorker instance that is created per PlayerTycoon instance.

```lua
--Defines the Cataloger for managing a local TycoonPurchaseIndex for a PlayerTycoon.
type Cataloger = {
    AddPurchaseToIndex: (Cataloger, number) -> (),
    CheckIndexContainsPurchase: (Cataloger, number) -> boolean,
    CheckIsUnlocked: (Cataloger, number) -> boolean,
    DistributePrerequisitesForPurchase: (Cataloger, number) -> (),
    GetCost: (Cataloger, number) -> number,
    GetPrerequisites: (Cataloger, number) -> {number},
    GetPurchasesWithAntirequisite: (Cataloger, number) -> {number},
    GetPurchasesWithPrerequisite: (Cataloger, number) -> {number},
    RemovePrerequisitesForPurchase: (Cataloger, number) -> (),
    TycoonPurchaseIndex: {[number]: PurchaseIndexNode},
} & UtilityTypes.CT
```