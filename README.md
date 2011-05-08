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
you should verify the recipes + settings in the `Vagrantfile` (see below),
then:

    $ vagrant up
    
Managing your Vagrantfile
-------------------------

Within your `Vagrantfile` the things you'll probably want to change are:

The name of your application (which will be the root folder of your project
inside of your VM):

    @application = "my_app" => @application => "billion_dollar_startup"

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

Controlling with Capistrano
---------------------------

You can use capistrano scripts to control your VM in the same way you control
your remote server (remember that you don't need to deploy to your VM thanks to
the NFS between your host and your VM).

To get started with capistrano, edit the file `deploy/recipes/environments.rb`
and properly set up your `development` environment by changing this:

    task :development do
      set :application, "my_app"
      set :user,        "vagrant"
      set :deploy_to,   "/srv/#{application}"

      role :app, "33.33.33.10"
    end

To something like this (note that it matches the names of things in your
Vagrantfile):

    task :development do
      set :application, "billion_dollar_startup"
      set :user,        "vagrant"
      set :deploy_to,   "/srv/#{application}"

      role :app, "33.33.33.123"
    end


Provisioning
------------

You can provision your servers with the same cookbooks you've used to provision
your VM. You need to set up a few things first:

Deploying
---------



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
