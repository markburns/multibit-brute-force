defmodule BruteForceTest do
  use ExUnit.Case

  import Pass.BruteForce, only: [
    run: 3,
    stop: 0
  ]

  @recovered_filename "tmp/recovered.key"

  setup do
    File.rm(@recovered_filename)
    stop
    :ok
  end

  test "with a valid password, it recovers the key file" do
    run(
    "test/support/empty-with-password.key",
    "test/support/with_valid_password.lst",
    @recovered_filename
    )

    :timer.sleep 800
    recovered_contents = File.read! @recovered_filename
    assert recovered_contents == "Found password\n{:password, \"password\", :contents, \"KzRtRhGd5yXHM9XpPV4jHbnP8SNhTWuZqNNRftMyEoXtgLCworcR 2015-11-30T11:23:08Z\\n\"}\n%{encrypted_contents: \"U2FsdGVkX19d7Uf6KHyMyAdbSkNiaqwA7o6LT5hhe45i+bv1v6lT1xiUEhhWs30QzKzHm4ooqT0x\\r\\nKOeB9aQcQBVJ8QRRp+iycWimKJ72tAKiczcQf6BzYLkmxPsKJYw5\\r\\n\", found_output_file: \"tmp/recovered.key\", password: \"password\"}"
  end

  test "with no valid passwords, it doesn't save the file" do
    run(
    "test/support/empty-with-password.key",
    "test/support/invalid_password.lst",
    @recovered_filename
    )

    {:error, :enoent} = File.read @recovered_filename
  end
end
