#!/usr/bin/env ruby

require 'ffi'

module Sysctl
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :sysctlbyname, [:string, :pointer, :pointer, :pointer, :ulong], :int

  class Timeval < FFI::Struct
    layout :tv_sec, :long,
           :tv_usec, :int32
  end
end

current_os = Gem::Platform.local.os

if current_os == 'darwin'
  len = FFI::MemoryPointer.new(:uint)
  len.write_uint(Sysctl::Timeval.size)
  boottime = Sysctl::Timeval.new
  Sysctl.sysctlbyname('kern.boottime', boottime, len, nil, 0)
  puts Time.now.to_i - boottime[:tv_sec]
elsif current_os == 'linux'
  puts File.read('/proc/uptime').split.first.to_i
end
