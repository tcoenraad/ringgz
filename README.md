ringgz
======

[![Build Status](https://travis-ci.org/tcoenraad/ringgz.png?branch=master)](https://travis-ci.org/tcoenraad/ringgz)

a ringgz server for programmeren 2 - Ruby edition  

*with chat and challenge support*

How to set-up
=============

    $ git clone https://github.com/tcoenraad/ringgz.git
    $ cd ringgz
    $ bundle install

How to run
==========

Run server:

    $ bundle exec ruby server.rb <port = 7269>

after this, any ringgz client following the protocol described in `lib/Protocol.java` can connect

Run specs:

    $ bundle exec rake

Screenshots
===========

![screenshot](http://i.imgur.com/HNF28u6.png)
