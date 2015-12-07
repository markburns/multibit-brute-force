defmodule Pass.Decrypt do
  def run(encrypted_contents, password) do
    decrypt(encrypted_contents, password)
  end

  def decrypt(encrypted_contents, password) do
    case Pass.KeyAndIvGenerator.run(encrypted_contents, password) do
      {_, key, iv, encrypted} -> decrypt(key, iv, encrypted)

      message                  -> IO.puts(message); {:error, message}
    end
  end

  def decrypt(key, iv, encrypted) do
    IO.inspect "key: #{key}"
    IO.inspect "iv: #{iv}"
    IO.inspect "encrypted: #{encrypted}"
    result = :crypto.aes_cbc_256_decrypt(key, iv, encrypted)

    IO.inspect result
    result
  end
end
