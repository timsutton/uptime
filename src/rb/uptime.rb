#!/usr/bin/env ruby

# TODO: implement instead with ffi so that we need to require
# (and build, and install) the ffi gem as part of the exercise

boottime = `sysctl -n kern.boottime`.chomp
                                    .split('=')[1]
                                    .split
                                    .first
                                    .gsub(',', '')
                                    .to_i
now = Time.now.to_i
puts now - boottime
