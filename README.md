# Rails Code Organization Showcase

In this repo, I present a way I usually organize my code. I'm using this way of organization for over 5 years. It worked great for me in 3 very different projects and was highly appreciated by my colleagues

Disclamer: this is a completely artificial example, not a sample of a real project's code. I have never launched this code, there may be typos or other "bugs". Please create an issue if you will spot some silly mistake somewhere.

## ToC

1. [System overview](#system-overview)
2. [Code structure](#code-structure)
3. [Execution Flow](#execution-flow)
4. [Core Concepts](#core-concepts)
    - [Layers](#layers)
    - [Operations](#operations)
5. [Responsibilities](#responsibilities)
6. [Design Decisions](#design-decisions)
7. [Further Improvements](#further-improvements)
8. [Discussion](#discussion)

## System Overview

The code in this repo models a part of an ads management service. It allows its users to manage their ads from different advertising plafroms in a single place. The system consists of a dashboard with various stats and controls over ads, and a bunch of integrations with ad platforms.

The only integration presented here is an integration with a fictional Acme Corporation. To add ads from that platform to the system, user must authorize our app via oauth through Acme-provided JS plugin. In order for us to be able to manage user's ads, that user must:

- Have an admin role in Acme system
- Grant us all the requested permissions
- Have an ad account on Acme side set up specifically for our system (say, it should have a specific name)
- Have specific set of permissions over that ad account

The modeled part consists of 2 sub-systems: **"ads management"** and **"acme integration"**, -- and 3 flows:

1. The addition of a new Acme ad account to the system. When the user finishes Acme oauth flow, our frontend sends us an API request to `POST /acme_integration/ad_accounts?access_token=` endpoint. Internally, that endpoint validates if preconditions are met and registers the ad account in our system

2. The syncronization of ads. The system has a pair of background jobs that sync the ads for all active acme ad accounts in the system: `AcmeIntegration::ScheduleAdsSyncJob` runs by cron every X minutes and schedules a `AcmeIntegration::SyncAdsJob`s for each ad account that should be synced

3. The deactivation of our services for a specific acme ad account. When user clicks a corresponding button in UI, FE sends `POST /ads_management/assets/:id/deactivations` request that triggers the deactivation

## Code Structure

- `/app/actions` stores classes that model system-facing parts of individual controller actions. Classes are named after the controller and action method they are used in.
- `/app/controllers`, `/app/jobs` and `/app/serializers` are self-evident
- `/app/models` stores domain objects: thin models with associations, scopes, some validations, but never the logic
- `/app/services` stores all the application logic, split into namespaces according to the sub-systems they model. In real codebase, it may also contain some other legacy not-yet-refactored stuff for which it is either:

    - still unclear which subdomain it belongs to
    - there was no need to change it since the new approach was adopted
    - it is too complex to refactor yet

- `/lib` stores gem-like code that is not application-specific

## Execution Flow

*TBD*

Picture:

```
          UI layer                                App layer
[controller -> action / job] -> [[Interface] -> Operation -> Operations]
```

(maybe also draw domain and infrastructure layers?)

## Core Concepts

*TBD*

### Layers

The code in this repo follows the ideas from layered architecture style and distinguishes 4 layers:

- **Presentation layer** is responsible for handling user interactions and presenting the information to users. In this repo, it consists of controllers, actions, serializers and maybe jobs (see the [Discussion](#discussion) section).

- **Application layer** consists of the business logic of the system, that is, the rules on how the data in the system is managed. In this repo, all the code that models business logic resides in the `/app/services` folder

- **Domain layer** represents the state of the system and consists of models. I keep models thin and only put associations, scopes and consistency-related validations into them

- **Infrastructure layer** holds gem-like code that solves specific low-level problems (api clients, logging, metrics, etc). In this repo, it is all stored in the `/lib` folder

I write my code in a way that each piece belongs to one and only layer. This helps to separate concenrs, keep rails aside from the business logic, increases testability and, most importantly, limits the number of reasons for which each unit of code may change. Controllers/actions/serializers change when the interface of the system changes, business logic in application layer change when requirements change, etc.

### FIXME

.....

(Sub-Systems, boundaries, data owners, interfaces)

### Operations

One of the problems I encounter in my work all the time is developers' confusion in where to put their business logic.

People ofter use terms like "service", "interactor", "use case", "business transaction", but everybody has a different opinion on what those terms mean. Often, several of them are used in the same code base, with no clear boundary between them. I saw code where an "interactor" is calling a "service", which internally calls another "interactor", and there seem to be no real difference between those, and nobody in the team can explain if there is any. This mess obviously doesn't help to improve readability/maintainability of the code.

The approach I use tries to solve that problem by limiting developer's toolbox with just two kinds of entities:

- Static immutable data structs with no associated behavior
- "Operation" classes that hold all the business logic

    (I deliberately chose a less popular term "operation" cause I think that developers will have less assumptions about it and thus less confusion. Also, that term really suits well)

This idea of data/behavior separation comes from functional programming, where you typically have data modelled as dumb immutable structs and behavior -- as functions. I've adopted it after watching the ["Functional Architecture for the Practical Rubyist"](https://www.youtube.com/watch?v=7qnsRejCyEQ) talk by Tim Riley, which I recommend everybody to watch.

The core thing about the operations in this code is that they are modelling processes instead of entities, which turns out to be very intuitive cause there usually is a clear mapping between how we think of what's happening and where it is implemented in the code:

- "User creates an Acme ad account" => `AcmeIntegration::AdAccounts::Create`
- "System syncronizes acme ads by cron" => `AcmeIntegration::Ads::Sync`

## Responsibilities

*TBD*

It is important to establish clear responsibilities for each kind of entity you have in the code. When enforced consistently, they remove a huge part of the burden of thinking where to put your code

### Controllers

A controller is a user-facing part of the presentation layer. It should know:

- Which request parameters are required/permitted (`params.require(...)` is actualy a validation)
- How to extract required parameters (including headers, locale, time zone, etc) from the request
- Which action to run
- A public interface of that action: which arguments it needs, which type is returned
- How to serialize the response (which serializer to use, which status code to set)
- How to serialize the error

### Actions

An action is a system-facing part of the presentation layer. It should know:

- Which parameters are required by the system (represented by a set of arguments)

    Note that in a general case request parameters doesn't have to match the inputs required by the system, so this is not the same responnsibility as controllers have

- Which entry point of the application layer to run
- A public interface of that entry point: which arguments it needs, which errors might be raised
- How to map the application-level errors into presentation-level errors

### Serialziers

A serializer should only be responsible for converting input object into JSON. This means: no data loading other than standard AR associations, no business logic. Even if you "just need your job to be done".

### Jobs

A job should be responbible:

- For it's own configuration: retries, queue, etc
- For knowing which entry point of the application layer to run
- A public interface of that entry point: which arguments it needs, which errors might be raised
- How to deal with errors: which ones should cause a retry, which should be suppressed

### Operations

For operations, responsibilities are determined by the process they model. Try to always ask youself if a particular thing you're willing to add to the operation is conceptually a part of that process your operation models.

### Exceptions

All the design decisions made here pursue a single goal: to make the code more maintainable, -- which includes ease of understanding, modification and testing. There are cases when implementing the whole chain controller -> action -> interface -> operation is just impractical in that sense.

For example, it is common for `#index` and `#show` endpoints to be pretty simple and not to mutate the application state. This two qualities, combined, already make them easy to understand, change and test. In such cases, strictly following the rules will harm readability, so I tend to break them and just put that logic into controllers "for now". If later the requirements will change in a way that'll require making that logic more complex, it would be trivial to move it into it's own operation.

I have no clear rules on what is an exception and what is not. I'd say that if the logic mutates the state, or if it is more complex than a single AR query, it usually does deserve it's own operation

## Design Decisions

*TBD*

## Further Improvements

In this part I speak about what might be improved further and when it is appropriate

*TBD*

- Use result monad from `dry-monads` instead of exceptions to control the flow
- Replace initializers with `dry_container` + `dry-auto_inject`
- Hide models behind repositories
- Extract sub-systems into separate gems with Rails engines inside
- Authorization system integrated with the `Subsystems::Interface`
- Create separate representations of a User within both subsystems, pass `user_public_id` into the subsystems instead of `user_id`
- Extract AdAccount's identity-related fields into an Identity model

## Discussion

*TBD*

### Models

.....

(Squash responsibilities of a repository and a data holder)

### Background Jobs

? In Rails, job classes combine two functions: when they are being scheduled, they act as an "API client" for a background processing service, when executed -- as part of a presentation layer of our system. While I'm not

### Input Validation

.....

(layers of validation)

### Authentication

.....

(a separate sub-system or a part of a presentation layer?)

### Authorization

.....

(layers of authz. Can identity access an endpoint? Can user perform operation X on a resource of kind Y? Does user own the resource?)





