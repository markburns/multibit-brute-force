defmodule Pass.Progress do
  use Timex
  use GenServer

  def start do
    Application.stop(Progress)
    GenServer.start_link(__MODULE__, nil, name: Progress)
  end

  def display(message) do
    GenServer.cast(Progress, {:display, message})
  end

  def handle_cast({:display, message}, state) do
    _display message

    {:noreply, state}
  end

  NIF
  defp _display(message) do
    #if message.index > 0 && (rem(message.index, 1000) == 0) do
      #IO.puts "trying password: #{inspect message.password}"
      #IO.puts "queue length: #{Queue.length}"

      percent = 100.0 * message.index / message.total
      time_diff = time_diff_from(message.start_time)

      IO.puts "(#{message.index}/#{message.total}) #{inspect percent}%  ETA: #{formatted_date(percent, time_diff)}"
      #end
  end

  defp time_diff_from(start_time) do
    time_diff = Date.diff start_time, Date.local, :secs
    if time_diff == 0 do
      1
    else
      time_diff
    end
  end

  defp formatted_date percent, time_diff do
    seconds_per_percent = if percent == 0 do
      0
    else
      time_diff / percent
    end
    diff = Time.to_timestamp((100.0 * seconds_per_percent), :secs)

    Date.local
    |> Date.add(diff)
    |> DateFormat.format!("%H:%M:%S, %a, %d %b %Y", :strftime)
  end
end
