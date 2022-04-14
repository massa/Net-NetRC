NAME
====

Net::NetRC - parse `.netrc` files

SYNOPSIS
========

```raku
use Net::NetRC;

my $x = netrc;

say $x<google.com><login>;

my $y = netrc 'machine azul.example.com login massa password j4k3';

say $y<azul.com><password>;

my $z = netrc '/home/myname/.netrc.alternate';
```

DESCRIPTION
===========

Net::NetRC is a basic parser for the `.netrc` file format.

I made it as a simple way of obtaining logins and passwords for many other projects.

AUTHOR
======

Humberto Massa <humbertomassa@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright © 2022 Humberto Massa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

