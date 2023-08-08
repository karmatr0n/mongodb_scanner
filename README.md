MongoDB Scanner
---------------
This a basic MongoDB scanner written in Ruby to collect the following
information:

* Hello handshake response (Wired version protocol, isWritablePrimary, SSL support, etc).
* BuildInfo (Version, Operating System, etc).
* Database list (if those are not protected by authentication).

Requirements
------------
* Ruby 3.2.2
* Bindata
* BSON
* OpenSSL

How to install dependencies
---------------------------
```
bundle install
```

Usage
-----
```
bin/mongodb_scanner -i <ip> -p <port>
```

or

```
bin/mongodb_scanner --help
```

LICENSE
-------
MIT

References
----------
* [Ruby](https://www.ruby-lang.org/en/)
* [BinData](https://github.com/dmendel/bindata)
* [BSON](https://github.com/mongodb/bson-ruby)
* [OpenSSL for Ruby](https://github.com/ruby/openssl)
* [minitest](https://github.com/minitest/minitest)

