# Rails Code Organization Showcase

## Core Concepts

**Business Logics layer** -- Code that implements the rules for how the data is managed and how it can be queried/changed by external actors

**UI layer** -- anything that provides a mechanism to interact with the Business Logics layer. Rails app, CLI, App window, etc. We have several UIs right now: API, Sidekiq, Admin Panel, Cron tasks, maybe something else as well (all happen to be implemented as a single Rails app)

_Layered architecture also distinguishes the Persistance layer but we're not talking about it here_

**Interactor** -- a boundary between business logics and UIs, part of the Business Logics layer. Specifies public interface to the business logics. Might serve as a boundary between subdomains within the Business Logics layer as well

**Business Operation** -- a piece of code that implements some part of the business logics. Something that can be described with a single verb (e.g. Create an account, syncronize account's assets, process webhook). Business operations can call one another, but only within the same subdomain

## Code Structure

You can think of the contents of `/app/controllers/` and `/app/actions` as belonging to the UI layer. `/app/services/` constitute a Business layer<sup>[[1]](#1)</sup>.

Within `/app/services/`, there are several subdomains, each having an `MySubdomain::Interface` class (this is our interactor), a bunch of Business Operations and a bunch of data objects, organized into subfolders by their semantics. If your operation may be described as "It syncronizes assets belonging to the MyIntegration identity", it'll probably rest in `MyIntegration::Assets::Syncronize` class or something alike.

Usually, `/app/services/` will also contain some other legacy not-yet-refactored stuff for which it is either:

- still unclear which subdomain it belongs to
- there was no need to change it since the new approach was adopted
- it is too complex to refactor yet

## Responsibilities

### UI layer

**Controllers** are responsible for knowing which action to call, how to render it's result/errors/exceptions, specifying the set of allowed http parameters, setting the user-related context (e.g. user locale, time zone), authentication

**Actions** are responsible for knowing which interaction to call, the set of parameters it needs, how to map business-layer errors into UI-layer errors (the ones that controllers know how to render)

### Business Logics layer

**Interfaces** are responsible for providing a complete set of available interactions with a subdomain. Additionally, they may have some service logics related to logging, metrics, etc. Each method within the interface knows which business operation should be called and if the logging is needed. Classical interactors should also care about input/output objects' formats, but I think in Ruby we don't need that and may let Business Operations care about those, just leave YARD comments listing params, return values and expected exceptions above each method

**Business Operations** are responsible for the actual logics. I prefer to model operations as objects-functions, which are simple POROs with a single public method `#call` and external dependencies (configs and other business operations) injected into the `#initialize` method. Whenever you need to create/update/delete a model, this should happen within some of the business operations, not in a method within a model class. Whenever you find yourself writing a callback in a model, stop and think of how to fit the logics into a business operation. Models are data, it's better to keep them static, without any logics. Only functions are dinamic, so business operations should manage all that. You can watch [this talk](https://www.youtube.com/watch?v=7qnsRejCyEQ) by Tim Riley, one of the authors of dry-rb, to better understand the benefits of this approach

**Data objects** are simple static immutable structs that are only responsible for holding data. I prefer to use [dry-struct](https://dry-rb.org/gems/dry-struct/1.0/) for them cause it has a good validation dsl and, once created, your code may trust the record to be valid (otherwise the code that is responsible for building that data object will crash, revealing that some of your expectations there are incorrect).

## Border Cases

### Models

In ActiveRecord models responsibilities are squashed: model classes serve as repositories while instances both represent data and act as repositories (when saving/updating/deleting/etc), which places models in between Business Logics and Persistance layers. I think it is fine to put scopes, associations, validations and read-only methods into models, but adding callbacks and any other business logics should be avoided and all the changes to model state should happen within the business operations.

### Background Jobs

They are in the gray zone. In one hand, Sidekiq can be viewed as an automated configurable clinet that triggers business logics accounrding to the rules defined by a programmer. Workers are like controllers in this analogy, which suggests that they should belong to the UI layer. But in the other hand, retry logics, queue preference (priority) and scheduling belongs to a domain. All this places bg jobs on the border between layers. Business operations will schedule jobs, jobs will call interactors. I think that within a single subdomain it is fine to schedule a job referencing it by name, whereas across subdomains an interactor should be used instead to capture the fact that it is a cross-subdomain call and thus it is a part of subdomains public interface.

### Input Validation.

I think that some validations should belong to the UI side (form/API params validation), others -- to the busniess side (internal business logics constraints).

When you validate form/API input, you're certain in which fields are required, what types to expect, string formats, enum variants etc. Validating all or most of this should belong to the UI layer cause all of those constraints are a part of the public interface of the business operation that happens when the form is submitted.

Business logics-related validations (the ones that depend on the system state) should belong to the business logics layer and happen within business operations. Otherwise, UI layer will need to check that sate which will break the inversion of dependencies which is not good. If the list of errors is one of the expected operation's outcomes, business operation may use a Result monad and return either a `Success` with a result object or a `Failure` with `ActiveModel::Errors`. Otherwise, it can just throw subdomain-layer exceptions with semantic names (e.g. `AccessTokenInvalidError`, `AccountNotFundedError`). It'll be a responsibility of a UI layer then to decide how to map those exceptions into user-friendly http errors with i18n-ized messages.

### Authentication

For simplicity, people usually just use device's `User` for both authentication and representation of a user but they don't really have to. If you think about it, nothing prevents the user from having multiple sets of credentials, which shows that those concepts can be separated. I think that credentials should belong to the UI layer whereas the user representation -- to the Business Logics layer. Credentials will then have a reference to the user. UI's responsibility is to check if the client is authenticated and then provide this reference along with the other parameters to the Business Logics interface.

While that holds for simple authentication cases, I'm still not sure how it'll work for the complex ones where you may need to track and invalidate devise sessions etc, cause I don't have real experience with such systems yet

### Authorization

I'm still not 100% sure here, but for me it looks like permissions/roles are a part of a business logics and thus should rest within it, not outside. Rails ecosystem is very kind to provide gems with simple mechanisms to do authorization right within a controller, but having it there forces controller to know about your business logics and the internal system state. Good at the start, might be bad later when it comes to organizing the code into subdomains cause controllers will know too much.

-----

<span id="1">1</span>. This structure is just the first step. On later stages, when subdomains emerge and boundaries between them are formed, one can choose to split them into separate gems (possibly, wrapping into Rails engines) or even into microserices.
