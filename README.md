mts2mp4
=======

MTS to mp4 file converter web interface

It requires Sinatra & Haml on ruby 1.9.3.
Avconv is used for conversion.

To start the web server. Just type the following
$ ruby start.rb
and access the server on 4567 port.

You can convert a file in the same orientation or left/right rotated.
Multifile conversion will be queued and processed sequencially.
