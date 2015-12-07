defmodule Pass.KeyAndIvGenerator do
  @doc """
    iex> {salt, key, iv, encrypted } = Pass.KeyAndIvGenerator.from_file "./test/support/empty-with-password.key", "password"
    iex> Base.encode16(salt)
    "5DED47FA287C8CC8"
    iex> Base.encode16(key)
    "5B4592909B724DAF300BC32CD247F94D8AB3A4F12F0CF098E5AA74ECA7B28012"
    iex> Base.encode16(iv)
    "344BC81AE09EED238652D052D822FE4C"
  """

  @magic_keyword "Salted__"
  @magic_keyword_length byte_size @magic_keyword

  def run(contents, password, key_size \\ 32, iv_size \\ 16) do
    {salt, encrypted} = separate_salt(contents)

    {key, iv} = key_and_iv(password, salt, key_size, iv_size)

    {salt, key, iv, encrypted}
  end

  def separate_salt(contents) do
    #FIXME: can't seem to extract salt from concatenated lines, only line_1
    [line_1, _, _] = contents |> String.split("\r\n")
    line_1 = Base.decode64!(line_1)

    <<
      _   :: binary-size(@magic_keyword_length),
      salt:: binary-size(8),
      _:: binary
    >> = line_1

    <<
      _   :: binary-size(@magic_keyword_length),
      _:: binary-size(8),
      encrypted:: binary
    >> = decode(contents)


    encrypted = Base.decode64!(encrypted)
    {salt, encrypted}
  end



  defp decode(contents) do
    contents
    |> String.replace "\r\n", ""
    |> Base.decode64!
  end


  def key_and_iv(password, salt, key_size, iv_size) do
    hash = _hash_to_length(password, salt, key_size*2, "", "")

    {
      hash |> String.slice(0,key_size-2),
      hash |> String.slice(key_size-2, iv_size)
    }
  end

  defp _hash_to_length(_password, _salt, keysize, _last, acc) when byte_size(acc) >= keysize do
    acc
  end

  defp _hash_to_length(password, salt, keysize, last, acc) do
    next = :crypto.hash(:md5, last <> password <> salt)
    _hash_to_length(password, salt, keysize, next, acc <> next)
  end
end
