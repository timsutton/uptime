#!/usr/bin/env ruby

require 'ffi'

current_os = Gem::Platform.local.os

if current_os == 'darwin'
  module Sysctl
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    attach_function :sysctlbyname, %i[string pointer pointer pointer ulong], :int

    class Timeval < FFI::Struct
      layout :tv_sec, :long,
             :tv_usec, :int32
    end
  end

  len = FFI::MemoryPointer.new(:uint)
  len.write_uint(Sysctl::Timeval.size)
  boottime = Sysctl::Timeval.new
  Sysctl.sysctlbyname('kern.boottime', boottime, len, nil, 0)
  puts Time.now.to_i - boottime[:tv_sec]

elsif current_os == 'linux'
  module Sys
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    class Sysinfo < FFI::Struct
      layout :uptime, :long,
             :loads, [:ulong, 3],
             :totalram, :ulong,
             :freeram, :ulong,
             :sharedram, :ulong,
             :bufferram, :ulong,
             :totalswap, :ulong,
             :freeswap, :ulong,
             :procs, :ushort,
             :pad, :ushort,
             :totalhigh, :ulong,
             :freehigh, :ulong,
             :mem_unit, :int,
             :_f, [:char, 0] # padding
    end

    attach_function :sysinfo, [Sysinfo.by_ref], :int
  end

  info = Sys::Sysinfo.new
  Sys.sysinfo(info)

  puts info[:uptime] # system uptime in seconds
end
