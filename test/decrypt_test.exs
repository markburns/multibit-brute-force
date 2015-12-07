defmodule DecryptTest do
  use ExUnit.Case

  import Pass.Decrypt, only: [
    run: 2,
  ]

  doctest Pass.Decrypt

  @unencrypted "KzRtRhGd5yXHM9XpPV4jHbnP8SNhTWuZqNNRftMyEoXtgLCworcR 2015-11-30T11:23:08Z\n"

  test ".decrypt" do
    key = Base.decode16!("5B4592909B724DAF300BC32CD247F94D8AB3A4F12F0CF098E5AA74ECA7B28012")
    iv  = Base.decode16!("344BC81AE09EED238652D052D822FE4C")
    encrypted = File.read!("test/support/key.bin")
    {:ok, result} = Pass.Decrypt.decrypt key, iv, encrypted
    assert  @unencrypted == result
  end

  test ".run with a valid key, it executes the openssl command returning the recovered key" do
    contents = File.read! "test/support/empty-with-password.key"
    {:ok, recovered_contents} = run(contents, "password")
    assert recovered_contents == @unencrypted
  end

  test ".run with an invalid key" do
    contents = File.read! "test/support/invalid.key"
    {:error, message} = run(contents, "password")
    assert message == "Couldn't decrypt bytes: %MatchError{term: [\"Salt___saltasdfgarbage\\n\"]}"
  end
end
