# frozen_string_literal: true

require "primesrs/ffi"
require "primesrs/version"

module Primesrs
  def self.[](n)
    search(n).to_a
  end
end
