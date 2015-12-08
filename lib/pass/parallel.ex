defmodule Pass.Parallel do
  @doc ~S"""
  Parallelizes the calculation of `fun` mapped over `collection`

  ## Examples
    iex> Pass.Parallel.map([1,2], fn({e, _})-> e + 2 end, 2)
    [3,4]
  """

  def map(collection, fun, total) do
    collection
    |> parallelize(self, fun, total)
    |> collate_results
  end

  def map(collection, fun) do
    collection
    |> parallelize(self, fun)
    |> collate_results
  end


  defp parallelize(list, me, fun, total) do
    list
    |> Stream.with_index
    |> display(total)
    |> Stream.map &(calculate_individual(me, fun, &1))
  end

  defp parallelize(list, me, fun) do
    list
    |> Stream.with_index
    |> Stream.map &(calculate_individual(me, fun, &1))
  end


  defp display(stream, total) do
    {el, index} = Stream.take(stream, 1) |> Enum.to_list |> List.first

    if rem(index, 1000) == 0 do
      IO.puts inspect el
      IO.puts "#{index} / #{total}"
      percent = 100.0 * index / total
      IO.puts "#{inspect percent}%"
    end

    stream
  end

  defp calculate_individual(me, fun, function_args) do
    spawn_link fn -> send(me, {self, fun.(function_args)}) end
  end

  defp collate_results list do
    list
    |> Enum.map(fn (pid) ->
      receive do {^pid, result} -> result end
    end)
  end
end
