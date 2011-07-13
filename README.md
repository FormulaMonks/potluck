Potluck
=======

Citrusbyte server provisioning + deployment repository

Potluck is a collection of Chef cookbooks & Capistrano recipes we use at
Citrusbyte primarily for provisioning and managing development environments
within virtual machines managed w/ Vagrant.

The same Chef recipes can then be used to provision remote servers (such as on
EC2, Slicehost, Linode, etc...) in the same fashion as our development
environments. This allows us to do a lot of nice things:

* Keeps our server setup managed in the same version control repository as our
application code.
* Makes it easy for new developers to pick up and start developing with the
same environment as everybody else.
* Minimizes discrepencies between our local settings and our staging/production
environment settings.
* Keeps our host machines clean of random gems and required packages.
* Allows us to script setup of development dependencies (i.e. fetching &
compiling 3rd-party libraries and their dependencies).
* Store, share and re-use server configuration (i.e. nginx configs, logrotate
settings, etc...)
* Automate setup steps that are typically relegated to a README.
* And more stuff I can't think of right now...

Note that the server provisioning scripts contained here are for very simple
server setups. They are primarily useful for small applications, experiments,
prototypes, staging environments, or alpha launches. While they have some of
the configuration of a small production environment (iptables rules, log
rotation, etc...), they are not intended for critical deployments. That said,
we try to keep them stable, and have had boxes managed by these cookbooks
chugging along for long periods.

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

Developing with Vagrant
=======================

Getting started
---------------

From your application root:

    $ ln -s deploy/files/Vagrantfile
    $ ln -s deploy/files/Capfile
    
Assuming you have Vagrant ready to go (if not, see http://www.vagrantup.com/),
you should verify the recipes + settings in the `Vagrantfile` (see below),
then:

    $ vagrant up
    
Managing your Vagrantfile
-------------------------

Within your `Vagrantfile` the things you'll probably want to change are:

The name of your application (which will be the root folder of your project
inside of your VM):

    @application = "my_app" => @application = "billion_dollar_startup"

If you find your running multiple VMs at the same time, you probably will
want them on separate IPs so they don't collide with one another.

    config.vm.network("33.33.33.10") => config.vm.network("33.33.33.123")

If you want other people on your local network to be able to get to your VM,
you will probably want to uncomment the port forwarding line. Doing so will
allow people on your local network to hit port 80 on your VM via port 4282 on
your host IP (i.e. `192.168.1.123:4282`):

    config.vm.forward_port("http", 80, 4282)

If you're going to be using Selenium for testing you will likely want to run
your VM with a gui so you can see what's going on and debug. To do so,
uncomment the boot_mode line:

    config.vm.boot_mode = :gui

Finally, check the cookbook names in the `chef.run_list` array. Each recipe
corresponds to the name of a cookbook in the `deploy/cookbooks` folder. The
default `run_list` looks like:

    chef.run_list = %w(
      recipe[apt]
      recipe[server]
      recipe[ruby192]
      recipe[logrotate]
      recipe[unicorn]
      recipe[nginx]
      recipe[redis]
      recipe[site]
    )

...to add Selenium to this list, you can just add it to the `run_list`:

    chef.run_list = %w(
      recipe[apt]
      recipe[server]
      recipe[ruby192]
      recipe[logrotate]
      recipe[unicorn]
      recipe[nginx]
      recipe[redis]
      recipe[selenium]
      recipe[site]
    ) # added selenium above site!

_NOTE_: You can change these at any time. Changes to the `run_list` or to the
actual recipes themselves can be updated by running:

    $ vagrant provision
    
...other changes to your configuration will require that you:

    $ vagrant halt
    $ vagrant up
    
See http://www.vagrantup.com/ for more info on using Vagrant.

_NOTE: Make sure to add `.vagrant` to your root `.gitignore` if you are using
git. This file is unique to the host machine and if it gets overwritten you
will have to rebuild your VM._

Controlling with Capistrano
---------------------------

You can use capistrano scripts to control your VM in the same way you control
your remote server (remember that you don't need to deploy to your VM thanks to
the NFS between your host and your VM).

To start/stop your application w/ shotgun (requires shotgun gem)

    $ cap development shotgun:start
    $ cap development shotgun:stop
    
Likewise for rackup (requires a config.ru)

    $ cap development rack:start
    $ cap development rack:stop
    
And, since your VM is configured similarly to your production servers, you can
also use the commands listed below under managing your production servers (i.e.
for unicorn, nginx, log tails, etc...).

_See `recipes/environments.rb` if you have trouble running commands against
your development environment._

Provisioning & Deployment
=========================

_NOTE: the instructions below assume you're deploying to the `production`
environment (as specified in `recipes/environment.rb`). If you're deploying to
a different environment, replace `production` with your environment name._

Server provisioning
-------------------

You can provision your servers with the same cookbooks you've used to provision
your VM.

You need to set up a couple things first:

_`environments.rb`_

`recipes/environments.rb` tells Capistrano about each of your server
environments. We use it to manage our servers for `production`, `staging`, and
any other environments we may be running. Before provisioning or deploying a
server, setup your appropriate environment according to the documentation in
the `recipes/environments.rb` file.

_`<environment>.dna.json`_
  
The `files/<environment>.dna.json` file is the server-side analogy to your
Vagrantfile. It contains environment-specific configuration to be read by chef
when provisioning your server. There is a sample file in
`files/sample.dna.json` which you need to copy for each environment you wish to
provision (i.e. `production.dna.json`). Once you have it copied, set it up
according to the contents of the file.

_NOTE: the `.gitignore` included with this repository ignores
`staging.dna.json` and `production.dna.json`. It is recommended that you leave
your environment-specific configuration files out of version control as they
typically contain sensitive information._

Once you are set up you can run:

    $ cap production provision:all
    
To get things started. This will install a minimal amount of things to get chef
up and running, and then continue the provisioning process using your chef
scripts.

Provisioning runs as the `root` user, so you will either need to supply the
`root` password when prompted, or you will need to be otherwise authorized to
ssh in as `root` (i.e. by adding your public key into 
`/root/.ssh/authorized_keys` on your server).

Once running, it will eventually prompt you for a Hostname & FQDN, we typically
use the application name and primary vhost, i.e.:

    $ Hostname: billion_dollar_startup
    $ FQDN: billiondollarstartup.com

Shortly after it will reboot in order to refresh the Hostname and FQDN, then
pick back up w/ chef provisioning. If chef provisioning fails, you can start it
again using:

    $ cap production provision:chef:all
  
Likewise, when you make changes to your VM and want to reflect the same changes
on your server, you can:

    $ cap production provision:chef:all

Deploying
---------

Set the password for the main user:

    $ ssh root@<production box>
    $ passwd admin
    
_Assuming you named your deploy user admin (the default)_

Read `~/.ssh/id_rsa.pub` on your host machine and put it into
`~/.ssh/authorized_keys` on the remote server so you don't have to enter a
password for the main user every time (it appends, so other people can run this
to put in their keys as well).

    $ cap production deploy:auth

The `server` chef recipe generates a deploy key for you on the server in
`~/.ssh/id_rsa.pub` -- you can run the following cap command to print it out,
then you can give it read access to your source repository for deployments (add
it as a deploy key on github, add it to gitosis, etc...)

    $ cap production deploy:key

Finally, you can run a deploy:

    $ cap production deploy

Or you can run a deploy with shutdown, maintenance page, and run your database
migrations (see `recipes/deploy.rb` for more detail):

    $ cap production deploy:long

If you see something like:

    ...
    ** [billion_dollar_startup :: err] Host key verification failed.
    ** [billion_dollar_startup :: err] fatal: The remote end hung up unexpectedly
    ...

Then you need to ssh in and do:

    $ cd ~ && git clone <your repo>.git

Which will prompt you if you want to connect, to which you should respond `yes`

Managing your server
--------------------

List all available capistrano commands:

    $ cap -T

Stop/start/restart unicorn:

    $ cap production unicorn:stop
    $ cap production unicorn:start
    $ cap production unicorn:restart

Restart nginx:

    $ cap production nginx:restart

Troubleshooting your server
---------------------------

Tail unicorn logs:

    $ cap production unicorn:tail:stderr
    $ cap production unicorn:tail:stdout

Tail nginx logs:

    $ cap production nginx:tail:error
    $ cap production nginx:tail:access

Todo
====

* Reduce manual steps as much as possible
* Get rid of configuration duplications between Vagrantfile and dna.json files

Contributors
============

* Mitchell Hashimoto
* Chris Schneider

License(s)
==========

These files contain multiple components of bundled software, and some of those
components are governed by an Apache license included in their respective
files. That license can be found at
http://www.apache.org/licenses/LICENSE-2.0.html

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
