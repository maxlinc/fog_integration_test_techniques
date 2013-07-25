# Fog Integration Testing

## Definitions

Note: The difference between various kinds of test doubles, especially [mocks vs stubs](http://www.martinfowler.com/articles/mocksArentStubs.html).  The definitions I'm using are from [xUnitPatterns](http://xunitpatterns.com/Test%20Double%20Patterns.html) as [summarized by Martin Fowler](http://www.martinfowler.com/bliki/TestDouble.html).  I believe these are the most accepted definitions in the Ruby community (they are used by [rspec-mocks](https://github.com/rspec/rspec-mocks).  However, they are inconsistent with the Fog usage of the term "mock".

## Overview

[Test Double](http://www.martinfowler.com/bliki/TestDouble.html) are an important part of a testing strategy for projects that integrate with Fog.  We recommend a [Test Pyramid](http://martinfowler.com/bliki/TestPyramid.html) approach, where the bulk of the tests at the bottom of the pyramid use a test double, but a few higher-level tests use a live implementation.  That will give you a good blend of fast feedback but also some slower but more realistic tests.

There are many reasons to use test doubles for any external service, but especially for cloud services, since:
* Tests could be very slow, especially for something like server creation
* Tests would incur charges
* Not all contributors have a fully functional account.  Some might not have any account, and other might not have all features enabled.
* Developers sharing a test account is not an ideal solution, because it can introduce problems with [lack of test isolation](http://martinfowler.com/articles/nonDeterminism.html#LackOfIsolation).
* The issues above are even more of an issue when dealing with open source contributions

## Types of Test Doubles

There are several choices of test doubles that can help test integration with Fog.  Let's review the kinds of test doubles before looking at the specific options.

The best way to deal with integrating with Fog in unit testing is to avoid interacting with Fog in the majority of the tests.  If your use of Fog is well [encapsulated](http://en.wikipedia.org/wiki/Encapsulation_%28object-oriented_programming%29) and avoids [leaky abstractions](http://en.wikipedia.org/wiki/Leaky_abstraction), then only a few units should interact directly with Fog.  You can use normal stub, mock or spy techniques (like those of [rspec-mocks](https://github.com/rspec/rspec-mocks)) to isolate the most tests from the units that interact with Fog.

The units that do interact with Fog, plus high-level testing (integration or functional testing) will probably use either:
> *Stubs* provide canned answers to calls made during the test, usually not responding at all to anything outside what's programmed in for the test.
>
> *Fake* objects actually have working implementations, but usually take some shortcut which makes them not suitable for production (an [InMemoryTestDatabase](http://www.martinfowler.com/bliki/InMemoryTestDatabase.html) is a good example).

## Options Summary



## High Level

###Fog.mock!

The simplest option is to use Fog's built-in stubbing system. Calling Fog.mock! will make providers replace their real implementations with implementations that just return stub data.  Since the stub data is very closely associated with the provider implementation in the Fog release, it is not easy for callers to customize the data or to update it between Fog releases.

Pros: There is no setup required other than calling Fog.mock!  This gives everyone access to a quick test double that may be suitable for most basic tests.

Cons:
Since the stub implementation is closely coupled with the provider implementation the quality and completeness of the stub implementation may vary from provider to provider, and there is no standard way to customize the stub data or to update it between Fog releases.  You may run into features that are not supported with Fog.mock!, that do not behave realistically, or that are not flexible enough for complex test scenarios.

Security Concerns: No actual accounts are used, so there is no risk of leaking sensitive data.

### VCR

[VCR](https://github.com/vcr/vcr) is an interesting type of test double known as a [Self-Initializing Fake](http://martinfowler.com/bliki/SelfInitializingFake.html).  It "initializes" itself by recording the real services the first time you run the test.  Later, you can replay the recorded responses.  VCR only works for HTTP and HTTPS protocols, so features that other transports like SSH or rsync will not work.

One great feature of a self-initializing fake is that any test that passes against a live service should pass with the fake.  The fake is recording real data from the live system, as it existed at a certain point in time.  So you should be able to easily switch the same exact test between real and fake implementations and get consistent results.  This isn't the case with the other alternatives here, where the stubbed data or behaviors can be significantly different from the live system.

Unfortunately, VCR cannot be just flipped on as easily as Fog.mock!  Make sure to read the Cons section before attempting to use VCR.

Pros: VCR can record the actual interactions with any HTTP service.  It is not coupled to the provider implementation, so you can easily record interactions for features that were not recorded by the provider.  You can also re-record the interactions at any time.  VCR also supports a variety of advanced features not available in Fog.mock! or most other frameworks, like [Automatic Re-recording](https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/cassettes/automatic-re-recording), [Dynamic ERB Cassettes](https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/cassettes/dynamic-erb-cassettes), and flexible [request matching strategies](https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/request-matching).

Cons: VCR will require significant customization before it is a useful test double.  VCR needs to record interactions the first time you run a test suite, so the first test run will be a slow, live test.  Also, with the default setup VCR would record and playback polling, which means that even rerunning tests could be quite slow.  You need to modify the VCR configuration to throw away polling requests if you want VCR to simulate servers being built quickly.

Security Concerns: Normally the VCR cassettes are committed, so that anyone can check out the project and run the tests with VCR acting as a test double.  However, since the VCR cassettes contain raw HTTP interactions there is a high chance of leaking sensitive data.  You need to be very careful about using techniques like [filter sensitive data](https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/configuration/filter-sensitive-data) or [hooks](https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/hooks) to keep the recorded cassettes clean.  You should also review the changes to cassettes before committing to avoid leaking anything.  Additional hooks and filters to minimize changes due to transient data (like the date) can help make this review easier.

Security Mitigation: Using a sandbox like TryStack could mitigate the risk of accidently leaking information.

## Low Level

### WebMock

VCR works by hooking into lower-level frameworks that can simulate HTTP responses, like WebMock.  If you're worried about automatically recording cassettes and would rather manually setup stub data, you could use WebMock directly.  If you only call a small number of services, WebMock might be a suitable choice.

Pros: WebMock will force you to manage stub data yourself.  This means it is less likely to leak sensistive data, but you'll need to be more aware of the HTTP API (instead of just the Fog methods).  This could also involve a lot of setup if you have many tests that need to stub different data or services.
