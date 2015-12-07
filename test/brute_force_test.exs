defmodule BruteForceTest do
  use ExUnit.Case

  import Pass.BruteForce, only: [
    run: 2,
  ]

  @tag :pending
  test "with a valid password, it recovers the key file" do
    {:ok, recovered_contents} = run("test/support/empty-with-password.key", "test/support/with_valid_password.lst")
    assert recovered_contents == "KzRtRhGd5yXHM9XpPV4jHbnP8SNhTWuZqNNRftMyEoXtgLCworcR 2015-11-30T11:23:08Z\n"
  end

  test "with no valid passwords" do
    {:error, message} = run(
      "test/support/empty-with-password.key",
      "test/support/invalid_password.lst"
    )

    assert message == "No valid password found"
  end
end
