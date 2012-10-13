Objective-C/Cocoa StatsD Client
==

A client for Etsy's StatsD server that runs on Objective-C/Cocoa.

We use it to instrument an internal OS X application with the same tools we
instrument the rest of our stack. 

StatsD is probably unsuitable for instrumenting a Mac desktop or iPhone
application that runs on client machines, because there's no
authentication/authorisation system, and no network reliability because it uses
UDP.
