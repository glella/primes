require 'ffi'

module Primesrs
  extend FFI::Library
  lib_name = "libprimesrs.#{::FFI::Platform::LIBSUFFIX}"
  ffi_lib File.expand_path(lib_name, __dir__)

  class ArrayFromRust < FFI::Struct
    layout :len, :size_t,
           :ptr, :pointer 

    def to_a
      self[:ptr].get_array_of_uint32(0, self[:len]).compact
    end
  end

  attach_function :search, [:uint], ArrayFromRust.by_value
end
