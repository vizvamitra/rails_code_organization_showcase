# Rails Code Organization Showcase

In this repo, I present a way I usually organize my code. I'm using this way of organization for over 5 years. It worked great for me in 3 very different projects and was highly appreciated by my colleagues

Disclamer: this is a completely artificial example, not a sample of a real project's code. I have never launched this code, there may be typos or other "bugs". Please create an issue if you will spot some silly mistake somewhere.

## ToC

1. [System overview](#system-overview)
2. [Code structure](#code-structure)
3. [Core Concepts](#core-concepts)
    - [Layers](#layers)
    - [Sub-systems](#subsystems)
    - [Operations](#operations)
    - [Data Owners](#data-owners)
4. [Responsibilities](#responsibilities)
5. [Design Decisions](#design-decisions)
6. [Further Improvements](#further-improvements)
5. [Discussion](#discussion)

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
- `/app/services` stores all the application logic, split into namespaces according to the sub-systems they model
- `/lib` stores gem-like code that is not application-specific

## Core Concepts

### Layers

The code in this repo follows the ideas from layered architecture style and distinguishes 4 layers:

- **Presentation layer** is responsible for handling user interactions and presenting the information to users. In this repo, it consists of controllers, actions, serializers and maybe jobs (see the [Discussion](#discussion) section).

- **Application layer** consists of the business logic of the system, that is, the rules on how the data in the system is managed. In this repo, all the code that models business logic resides in the `/app/services` folder

- **Domain layer** represents the state of the system and consists of models. I keep models thin and only put associations, scopes and consistency-related validations into them

- **Infrastructure layer** holds gem-like code that solves specific low-level problems (api clients, logging, metrics, etc). In this repo, it is all stored in the `/lib` folder

I write my code in a way that each piece belongs to one and only layer. This helps to separate concenrs, keep rails aside from the business logic, increases testability and, most importantly, limits the number of reasons for which each unit of code may change. Controllers/actions/serializers change when the interface of the system changes, business logic in application layer change when requirements change, etc.

### Sub-Systems

*TBD*

Often systems consist of several logical parts that have few in common

### Operations

*TBD*

This idea of data/behavior separation comes from functional programming, where you typically have data modelled as dumb immutable structs and behavior -- as functions. I've adopted it after watching the ["Functional Architecture for the Practical Rubyist"](https://www.youtube.com/watch?v=7qnsRejCyEQ) talk by Tim Riley, which I recommend everybody to watch.

### Data Owners

*TBD*

## Responsibilities

*TBD*

## Design Decisions

*TBD*

## Further Improvements

In this part I speak about what might be improved further and when it is appropriate

*TBD*

- Use result monad from `dry-monads` instead of exceptions to control the flow
- Replace initializers with `dry_container` + `dry-auto_inject`
- Hide models behind repositories
- Extract sub-systems into separate gems with Rails engines inside
- Create separate representations of a User within both subsystems, pass `user_public_id` into the subsystems instead of `user_id`
- Extract AdAccount's identity-related fields into an Identity model

## Discussion

### Models

*TBD*

### Background Jobs

*TBD*

### Input Validation

*TBD*

### Authentication

*TBD*

### Authorization

*TBD*





