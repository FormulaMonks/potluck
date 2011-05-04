Potluck
=======

Citrusbyte server provisioning + deployment repository

Usage
=====

Installing
----------

Clone into your application repository under deploy:

    $ git clone git://github.com/citrusbyte/potluck.git deploy
    
Then you should:

    $ rm -rf deploy/.git

And maintain changes to the base provisioning/deployment repository within your
own code-base.

Getting started
---------------

From your application root:

    $ ln -s deploy/files/Vagrantfile
    $ ln -s deploy/files/Capfile
    
Assuming you have Vagrant ready to go (if not, see http://www.vagrantup.com/),
you should verify the recipes + settings in the @Vagrantfile@, then:

    $ vagrant up

Provisioning
------------

...

Deploying
---------

...

Contributors
============

Mitchell Hashimoto: original Vagrantfile

License(s)
==========

This software consists of multiple pieces of bundled software, some of which
contain a separate but compatible license from the license below. Unless
otherwise noted, the license below applies to all components contained within.

Copyright (c) 2009, 2010, 2011 Ben Alavi & Tim Goh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
