defmodule Stuff do
  def decode(salt_length \\ 10, filename \\ "./test/support/empty-with-password.key") do
    contents = File.read! filename
    [a,b,_] = String.split contents, "\r\n"

    a = Base.decode64!(a)
    b = Base.decode64!(b)

    a
    a = remove_salt a, salt_length

    #a
  end

  def remove_salt(a, salt_length) do
    len = byte_size a

    binary_part(a, salt_length,len - salt_length)
  end
end
