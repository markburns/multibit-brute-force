defmodule Pass.Decrypt do
  def run(encrypted_filename, password) do
    decrypt(encrypted_filename, password)
  end

  def decrypt(encrypted_filename, password) do
    case Pass.KeyAndIvGenerator.from_file(encrypted_filename, password) do
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
