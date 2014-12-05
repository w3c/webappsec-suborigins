<section id="abstract">
This specification defines a mechanism by which a server may specify a web
resource response a new origin in the user agent which is a combination of the
server's origin and a specified namespace.
</section>

<section id="sotd">
A list of changes to this document may be found at
<https://github.com/w3c/webappsec>.
</section>

<section class="informative">
### Introduction

Currently, web applications are almost always compartmentalized by using
separate host names to establish separate web origins. This is useful for
helping to prevent XSS and other cross-origin attacks, but has many unintended
consequences. For example, it causes latency due to additional DNS lookups,
removes the ability to use single-origin features (such as the
history.pushState API), and creates cryptic host name changes in the user
experience. Perhaps most importantly, it results in an extremely inflexible
architecture that, once rolled out, cannot be easily and transparently changed
later on.

There are several mechanisms for reducing the attack surface for XSS without
creating separate host-name based origins, but each pose their own problems.
Per-page Suborigins is an attempt to fill some of those gaps. Two of the most
notable mechanisms are Sandboxed Frames and Content Security Policy (CSP). Both
are powerful but have shortcomings and there are many external developers
building legacy applications that find they cannot use those tools.

Sandboxed frames can be used to completely separate untrusted content, but they
pose a large problem for containing trusted but potentially buggy code because
it is very difficult, by design, for them to communicate with other frames. The
synthetic origins assigned in a sandboxed frame are random and unpredictable,
making the use of postMessage and CORS difficult. Moreover, because they are by
definition unique origins, with no relationship to the original origin,
designing permissions for them to access resources of the original origin would
be difficult.

Content Security Policy is also promising but is generally incompatible with
current website design. Many notable companies found it impractical to retrofit
most of their applications with it. On top of this, until all applications
hosted within a single origin are simultaneously put behind CSP, the mechanism
offers limited incremental benefits, which is especially problematic for
companies with large portfolios of disparate products all under the same domain.

[comparing origins]: http://tools.ietf.org/html/rfc6454#section-5

<section>
### Goals

1. Provide a way for different applications hosted at the same real origin to
separate their content into separate logical origins. For example,
https://foobar.com/application and https://foobar.com/widget, today, are, by
definition, in the same origin, even if they're different applications. Thus an
XSS at https://foobar.com/application means an XSS at
https://foobar.com/widget, even if https://foobar.com/widget is "protected" by
a strong Content Security Policy.

2. Similarly, provide a way for content authors to split their applications
into logical modules with origin level separation without using different real
origins. Content authors should not have to choose between putting all of their
content in the same origin, on different real origins, or putting content in
anonymous unique origins (sandboxes).

3. Provide a way for content authors to attribute different permissions such as
cookie access, storage access, etc. to different suborigins.


Not sure how to actually refer to 'real origins'. This is a terrible name, and
we need a better way to talk about them. Maybe physical origin? Traditional
origin? (jww)
{:.issue}
</section><!-- /Introduction::Goals -->

<section>
### Use Cases/Examples

We see effectively three different use cases for Per-page Suborigins:

1. Separating distinct applications that happen to be served from the same
domain, but do not need to extensively interact with other content. Examples
include marketing campaigns, simple search UIs, and so on. This use requires
very little engineering effort and faces very few constraints; the applications
may use XMLHttpRequest and postMessage to communicate with their host domain as
required.

1. Allowing for modularity within a larger web application by splitting the
functional components into different suborigins. For example, Gmail might put
the contacts widget, settings tab, and HTML message views in separate Per-page
Suborigins. Such deployments may require relatively modest refactorings to
switch to postMessage and CORS where direct DOM access and same-origin
XMLHttpRequest are currently used, but we believe doing so is considerably
easier than retrofitting CSP onto arbitrary code bases and can be done very
incrementally.

3. Similar to (2), applications with many users can split information relating
to different users into their own suborigin. For example, Twitter might put
each user profile into a unique suborigin so that an XSS within one profile
cannot be used to immediately infect other users or read their personal
messages stored within the account.

</section><!-- /Introduction::Use Cases/Examples -->
</section><!-- /Introduction -->

<section id="conformance">

Conformance requirements phrased as algorithms or specific steps can be
implemented in any manner, so long as the end result is equivalent. In
particular, the algorithms defined in this specification are intended to
be easy to understand and are not intended to be performant. Implementers
are encouraged to optimize.

<section>
### Key Concepts and Terminology

This section defines several terms used throughout the document.

</section> <!-- /Conformance::Key Concepts and Terminology -->
</section> <!-- /Conformance -->

<section>
### Framework

<section>
### Defining a Suborigin

As per the origin spec...

<section>
### Serialization

</section> <!-- /Framework::Defining a Suborigin::Serialization -->

<section>
### Accessing the Suborigin in JavaScript

</section> <!-- /Framework::Defining a Suborigin::Accessing the Suborigin in JavaScript -->

</section> <!-- /Framework::Defining a Suborigin -->

<section>
### Access Control

<section>
### CORS

</section> <!-- /Framework::Access Control::CORS -->

<section>
### Postmessage

</section> <!-- /Framework::Access Control::Postmessage -->

<section>
### Workers

</section> <!-- /Framework::Access Control::Workers -->

</section> <!-- /Framework::Access Control -->

</section> <!-- /Framework -->

<section>
### Impact on Web Platform

<section>
### Examples

</section> <!-- /Impact on Web Platform::Examples -->

<section>
### Relationship with Sensitive Permissions

DOM storage, cookies, document.domain, etc.

</section> <!-- /Impact on Web Platform::Relationship with Sensitive Permissions -->

</section> <!-- /Impact on Web Platform -->

<section>
### Algorithms

Similar to comparison and serialization sections in Origin Spec:
https://tools.ietf.org/html/rfc6454

</section> <!-- /Algorithms -->

<section>
### Security Considerations

<section>
### Data leakage

</section> <!-- /Security Considerations::Data leakage -->

<section>
### Presentation of Suborigins to Users

</section> <!-- /Security Considerations::Presentation of Suborigins to Users -->

<section>
### Not Overthrowing Same-origin Policy

</section> <!-- /Security Considerations::Not Overthrowing Same-origin Policy -->

</section> <!-- /Security Considerations -->
