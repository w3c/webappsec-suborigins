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

The term <dfn>origin</dfn> is defined in the Origin specification.
[[!RFC6454]]

</section> <!-- /Conformance::Key Concepts and Terminology -->
</section> <!-- /Conformance -->

<section>
### Framework

<section>
### Defining a Suborigin

Origins are a mechanism for user agents to group URIs into protection domains.
Two URIs are in the same origin if they share the same scheme, host, and port.
If URIs are in the same origin, then they share the same authority and can
access all of each others resources.

This has been a successful mechanism for privilege separation on the Web.
However, it does limit the ability of a URI to separate itself into a new
protection domain as it automatically shares authority with all other identical
origins, which are defined by physical, rather than programatic, properties.
While it is possible to setup unique domains and ports different parts of the
same application (scheme is more difficult to separate out), there are a diverse
set of practical problems in doing so.

Suborigins provide a mechanism for creating this type of separation
programatically. Any resources may provide, in a manner detailed below, a string
value <dfn>suborigin namespace</dfn>.  If either of two URIs provide a suborigin
namespace, then the two URIs are in the same origin if and only if they share
the same scheme, host, port, and suborigin namespace.

Q. In today's Web, can't a site get the effective same protection domain simply
by hosting their content at different subdomains?

A. Yes, but there are many practical reasons why this is difficult.

[suborigin namespace]: #dfn-suborigin-namespace

<section>
### Examples

#### Separate applications, same origin
Google runs Search and Maps on the same domain, respectively
`https://www.google.com` and `https://www.google.com/maps`. While these two
applications are fundamentally separate, there are many reasons for hosting them
on the same origin, including historical links, branding, and performance.
However, from security perspective, this means that a compromise of one
application is a compromise of the other since the only security boundary in the
browser is the origin, and both applications are hosted on the same origin.
Thus, even if Google Search were to successful implement a strong Content
Security Policy [[CSP]], if Google Maps were to have an XSS vulnerability, it
would be equivalent to having an XSS on Google Search as well, negating Google
Search's security measures.

#### Separation within a single application
Separation is sometimes desirable within a single application because of the
presence of untrusted data. Take, for example, a social networking site with
many different user profiles. Each profile contains lots of untrusted content
created by a single user but it's all hosted on a single origin. In order to
separate untrusted content, the application might want a way to put all profile
information into separate logical origins while all being hosted at the same
physical origin. Furthermore, all content within a profile should be able to
access all other content within the same origin, even if displayed in unique
frames.

This type of privilege separation within an application has been shown to be
valuable and reasonable for applications to do by work such as
Privilege Separation in HTML5 Applications by Akhawe et al
[[PrivilegeSeparation]]. However, these systems rely on cross frame messaging
using `postMessage` even for content in the same trust boundary since they
utilize `sandbox`. This provides much of the motivation for the named container
nature of suborigins.

</section> <!-- /Framework::Defining a Suborigin::Examples -->

<section>
### Relationship of Suborigins to Origins

Suborigins, in fact, do not provide any new authority to resources. Suborigins
simply provide <em>an additional way to construct Origins</em>. That is,
Suborigins do not supercede Origins or provide any additional authority above
Origins. From the user agent's  perspective, two resources in different
Suborigins are simply in different Origins, and the relationship between the two
resources should be the same as any other two differing origins as described in
[[!RFC6454]].  Thus, this specification is intended to provide the following two
important properties:

* The rules on how Suborigins are defined.
* The rules on how Suborigins are tracked.

</section> <!-- /Framework::Defining a Suborigin::Relationship of Suborigins to Origins-->

<section>
### Serialization

At an abstract level, a suborigin consists of a scheme, host, and port of a
traditional origin, plus a [suborigin namespace][]. However, as mentioned above,
suborigins are intended to fit within the framework of [[!RFC6454]]. Therefore,
this specification provides a way of serializing a Suborigin bound resource into
a traditional Origin. This is done by inserting the suborigin namespace into the
scheme space of the Origin, thus creating a new scheme but maintaining all of
the information about both the original scheme and the suborigin namespace. This
is done by inserting a `+` into the URI after the scheme, followed by the
suborigin namespace, then followed by the rest of the URI starting with `:`.

For example, if the resource is hosted at `https://example.com/` in the
suborigin namespace `profile`, this would be serialized as
`https+profile://example.com/`.

Similarly, if a resource is hosted at `https://example.com:8080/` in the
suborigin namespace `separate`, this would be serialized as
`https+separate://example.com:8080/`.
</section> <!-- /Framework::Defining a Suborigin::Serialization -->

<section>
### Opting into a Suborigin

Unlike the `sandbox` attribute, suborigin namespaces are predictable and
controllable. Because of this, potentially untrusted content cannot opt into
suborigins, unlike iframe sandboxes. If they could, then an XSS on a site could
enter a specific suborigin and access all of its resources, thus violating the
entire privilege separation suborigins are intended to protect. To prevent
this, the server (rather than a resource itself) is treated as the only
authoritative source of the suborigin namespace of a resource. This is
implemented through an additional header-only Content Security Policy directive
`suborigin`, which takes a string value that is the namespace. For example, to
put a resource in the `testing` suborigin namespace, the server would specify
the following directive in the CSP header:

    suborigin: testing

</section> <!-- /Framework::Defining a Suborigin::Opting into a Suborigin -->

<section>
### Accessing the Suborigin in JavaScript
I don't have a great idea for how to do this yet. Should it be as simple as
document.location.suborigin? Or should it be serialized into document.origin,
plus a deserialization mechanism? (jww)
{:.issue}

</section> <!-- /Framework::Defining a Suborigin::Accessing the Suborigin in JavaScript -->

</section> <!-- /Framework::Defining a Suborigin -->

<section>
### Access Control

Cross-origin (including cross-suborigin) communication is tricky when suborigins
are involved because they need to be backwards compatible with user agents that
do not support suborigins while providing origin-separation for user agents that
do support suborigins. The following discussions discuss the three major
cross-origin mechanisms that are relevant.

<section>
### CORS

For pages in a suborigin namespace, all `XMLHttpRequest`s to any URL should be
treated as cross-origin, thus triggering CORS [[!CORS]] logic with special
`Finer-Origin:` and `Suborigin:` headers added. Additionally, the `Origin:`
header that is normally applied to cross-origin requests should <em>not</em> be
added. These header changes are needed so that a server that recognizes
suborigins can see the suborigin namespace the request is coming from and apply
the appropriate CORS headers as is appropriate, while legacy servers will not
"accidentally" approve cross-origin requests because of an `Origin` header that
provides an incomplete picture of the origin (that is, an origin without the
suborigin).

The `Finer-Origin:` header takes a value identical to the Origin Header, as
defined in [[!RFC6454]]. The `Suborigin:` header takes a string value that is
the suborigin namespace. The former servers identically as the `Origin:` header,
but in a purposefully backwards incompatible way, while the `Suborigin:` header
allows a server to make a more nuanced access control choice. A user agent must
not include more than one `Finer-Origin:` header and must not include more than
one `Suborigin:` field.

Similar changes are needed for response from the server with the addition of
`Access-Control-Allow-Finer-Origin` and `Access-Control-Allow-Suborigin`
response headers. The former takes the same values as
`Access-Control-Allow-Origin` as defined in [[!CORS]], while the later takes a
string value that matches allowed suborigin namespaces, or `*` to allow all
suborigin namespaces.

I expect that this will be a relatively controversial part of the proposal, but
I think the concern is pretty important. In particular, a lot of the potential
benefits of the proposal are eliminated if the Origin header is set with the
broad, traditional origin as an isolated but compromised suborigin could just
request private information from the other origin. That having been said, we
might be able to bypass a lot of these concerns by using the Origin header but
putting the serialized suborigin as described above it its place. This would
require monkey patching the Origin spec's syntax of the Origin header.
{:.issue}

</section> <!-- /Framework::Access Control::CORS -->

<section>
### postMessage

Cross-origin messaging via `postMessage` [[!WebMessaging]] provides many of the
same concerns as CORS. Namely, it is necessary for the recipient to see the
suborigin namespace of the message sender so an appropriate access control
decision can be made, and similarly, legacy applications should by default treat
these messages as not coming from the traditional origin of the sender.

To enforce this, when a message is sent from a suborigin namespace, the receiver
has the `event.origin` value set to `null` so if it is read, it is not treated
as coming from any particular origin. Instead, new propriets of
`event.finerorigin` and `event.suborigin` should be set the scheme/host/port and
suborigin namespace, respectively.

Similar to the CORS case, another option is to set `event.origin` to the
serialized namespace and then provide a deserialization tool.
{:.issue}

</section> <!-- /Framework::Access Control::postMessage -->

<section>
### Workers
We need a story here. I basically think that workers should be treated as
if they're in the same suborigin as whatever created them, but I'm also open to
other suggestions. Particularly tricky are service workers, which for simplicity
sake I suggest we treat as applying universally to all suborigins at a single
physical origin since it works in terms of network requests, and suborigins are
not relevant to network requests. Pull requests welcome.
{:.issue}

</section> <!-- /Framework::Access Control::Workers -->

</section> <!-- /Framework::Access Control -->

</section> <!-- /Framework -->

<section>
### Impact on Web Platform

Content inside a suborigin namespace is severely restricted in what the hosted
content can do. The restrictions match the behavior of an iframe with the
sandbox attribute set to the value of `allow-scripts` [[!HTML]]. While more
specifics are described below, the general idea here is to put suborigin
namespaces in a "default secure" context. However, restrictions may be lifted
going forward at a time when a way to whitelist particular Web platform
permissions is well-defined.

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
