defmodule Pass.Decrypt do
  use Timex

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
    result = unpad(:crypto.block_decrypt(:aes_cbc256, key, iv, encrypted))

    check result
  rescue
    message ->
      encrypted = encrypted |> Base.encode16
      {:error, "Couldn't decrypt bytes #{inspect message} #{encrypted}"}
  end

  defp check(result) do
    if String.printable? result do
      {:ok, result}
    else
      {:error, "invalid decryption"}
    end
  end

  defp unpad(binary) do
    case  String.printable?(binary)  do
      true -> binary

      false ->
        <<last>> = String.last(binary)
        String.rstrip(binary, last)
    end
  end
end
