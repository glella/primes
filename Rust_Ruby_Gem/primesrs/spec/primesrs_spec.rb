# frozen_string_literal: true

RSpec.describe Primesrs do
  it "has a version number" do
    expect(Primesrs::VERSION).not_to be nil
  end

  it "gets prime numbers" do
    expect((Primesrs[10]).sort!).to match_array([2,3,5,7])
  end
end
