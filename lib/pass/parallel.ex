defmodule Pass.Parallel do
  use Timex

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


  defp parallelize(list, me, fun, total, start_time \\ Date.now(:secs)) do
    list
    |> Stream.with_index
    |> display(total, start_time)
    |> Stream.map &(calculate_individual(me, fun, &1))
  end

  defp parallelize(list, me, fun) do
    list
    |> Stream.with_index
    |> Stream.map &(calculate_individual(me, fun, &1))
  end


  defp display(stream, total, start_time) do
    {el, index} = Stream.take(stream, 1) |> Enum.to_list |> List.first

    if rem(index, 1000) == 0 do
      percent = 100.0 * index / total

      IO.puts inspect el
      IO.puts "completed: #{index} / #{total}"
      IO.puts "#{inspect percent}%"

      now = Date.now(:secs)
      time_diff = now - start_time

      if time_diff > 0 do
        IO.puts time_diff

        percent_per_second = percent / time_diff
        eta = now + (100.0 / percent_per_second)
        formatted_date = eta |> DateFormat.format("%a, %d %b %Y %H:%M:%S", :strftime)

        IO.puts "ETA: #{formatted_date}"
      end

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
