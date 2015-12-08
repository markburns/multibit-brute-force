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


  defp parallelize(list, me, fun, total, start_time \\ Date.now) do
    list
    |> Stream.with_index
    |> Stream.each(&(display(&1, total, start_time)))
    |> Stream.map(&(calculate_individual(me, fun, &1)))
  end

  defp parallelize(list, me, fun) do
    list
    |> Stream.with_index
    |> Stream.map &(calculate_individual(me, fun, &1))
  end


  defp display({el, index}, total, start_time) do
    if (rem(index, 10) == 0) do
      IO.puts "trying password: #{inspect el}"
      IO.puts "completed: #{index} / #{total}"

      percent = 100.0 * index / total
      IO.puts "#{inspect percent}%"

      time_diff = time_diff_from(start_time)

      IO.puts "ETA: #{formatted_date(percent, time_diff)}"
    end
  end

  defp time_diff_from(start_time) do
    time_diff = Date.diff Date.now, start_time, :secs
    time_diff = if time_diff == 0 do
      1
    else
      time_diff
    end
  end

  defp formatted_date percent, time_diff do
    percent_per_second = percent / time_diff
    percent_per_second = if percent_per_second == 0 do
      1
    else
      percent_per_second
    end
    diff = Time.to_timestamp((100.0 / percent_per_second), :secs)
    eta = Date.add Date.now, diff
    eta |> DateFormat.format!("%a, %d %b %Y %H:%M:%S", :strftime)
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
