defmodule KeyAndIvGeneratorTest do
  use ExUnit.Case

  import Pass.KeyAndIvGenerator, only: [
    key_and_iv: 4,
    key_and_iv: 2,
    separate_salt: 1,
    salt_from: 1,
    encrypted_from: 1,
    run: 2
  ]

  doctest Pass.KeyAndIvGenerator

  @salt     "5DED47FA287C8CC8"
  @filename "./test/support/empty-with-password.key"
  @iv       "344BC81AE09EED238652D052D822FE4C"
  @key      "5B4592909B724DAF300BC32CD247F94D8AB3A4F12F0CF098E5AA74ECA7B28012"

  test ".salt_from extracts the salt from raw encrypted file" do
    contents = File.read! @filename
    salt = salt_from contents
    assert e(salt) == @salt
  end

  test ".encrypted_from extracts the raw AES encryped text from file contents" do
    contents = File.read! @filename

    encrypted = encrypted_from contents

    assert encrypted == File.read!("./test/support/key.bin")
  end

  test ".key_and_iv generates the key and iv from password and salt" do
    {key, iv} = encode16 key_and_iv("password", Base.decode16!(@salt))

    assert key == @key
    assert iv  == @iv
  end

  test ".separate_salt extracts the salt from raw encrypted file" do
    contents = File.read! @filename

    {salt, _} = separate_salt(contents)
    assert salt == Base.decode16!(@salt)
  end

  test ".run extracts from encrypted file contents" do
    contents = File.read! @filename
    {salt, key, iv, encrypted} = encode16 run(contents, "password")

    assert salt == @salt
    assert key  == @key
    assert encrypted == e File.read!("./test/support/key.bin")
    assert iv   == @iv
  end

  defp encode16({key, iv}) do
    {e(key), e(iv)}
  end

  defp encode16({salt, key, iv, encrypted}) do
    {e(salt), e(key), e(iv), e(encrypted)}
  end

  defp e(v) do
    Base.encode16(v)
  end
end

