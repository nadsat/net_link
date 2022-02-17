defmodule NetLinkTest do
  use ExUnit.Case
  doctest NetLink

  test "greets the world" do
    assert NetLink.hello() == :world
  end
end
