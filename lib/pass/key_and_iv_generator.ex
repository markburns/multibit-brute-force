defmodule Pass.KeyAndIvGenerator do
  @magic_keyword "Salted__"
  @magic_keyword_length byte_size @magic_keyword

  def run(contents, password, key_size \\ 32, iv_size \\ 16) do
    {salt, encrypted} = separate_salt(contents)

    {key, iv} = key_and_iv(password, salt, key_size, iv_size)

    {salt, key, iv, encrypted}
  end

  def separate_salt(contents) do
    salt      =      salt_from(contents)
    encrypted = encrypted_from(contents)

    {salt, encrypted}
  end

  def salt_from(contents) do
    #FIXME: can't seem to extract salt from concatenated lines, only line_1
    [line_1, _, _] =  contents |> String.split("\r\n")

    line_1 = Base.decode64!(line_1)

    <<
    _    :: binary-size(@magic_keyword_length),
    salt :: binary-size(8),
    _    :: binary
    >> = line_1
    salt
  end

  def encrypted_from(contents) do
    decoded = contents |> String.replace("\r\n", "") |> Base.decode64!

    <<
    _         :: binary-size(@magic_keyword_length),
    _         :: binary-size(8),
    encrypted :: binary
    >> = decoded

    encrypted
  end

  def key_and_iv(password, salt, key_size \\ 32, iv_size \\ 16) do
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
