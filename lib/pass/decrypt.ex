defmodule Pass.Decrypt do

  def run(encrypted_contents, password) do
    case Pass.KeyAndIvGenerator.run(encrypted_contents, password) do
      {_, key, iv, encrypted} -> decrypt(key, iv, encrypted)
      {:error, message}       -> {:error, message}
    end
  rescue
    error ->
      {:error, "Couldn't decrypt bytes: #{inspect error}"}
  end

  def decrypt(key, iv, encrypted) do
    result = unpad(:crypto.aes_cbc_256_decrypt(key, iv, encrypted))

    {:ok, result}
  rescue
    message ->
      encrypted = encrypted |> Base.encode16
      {:error, "Couldn't decrypt bytes #{inspect message} #{encrypted}"}
  end

  def unpad(binary) do
    case  String.printable?(binary)  do
      true -> binary

      false ->
        <<last>> = String.last(binary)
        String.rstrip(binary, last)
    end
  end
end
