defmodule Queue do
  use GenServer
  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: Queue)
  end

  def enqueue(item) do
    GenServer.cast(Queue, {:enqueue, item})
  end

  def dequeue do
    GenServer.call(Queue, :dequeue)
  end

  def length do
    GenServer.call(Queue, :length)
  end

  def handle_call(:length, _from, state) do
    len = length(state)
    Logger.error "calling length: #{len}"
    {:reply, length(state), state}
  end

  # Callbacks
  def handle_call(:dequeue, _from, state) do
    Logger.error "DEQUEUEING"
    last = List.last(state)
    state = List.delete(state, last)
    result = {:reply, last, state}
    Logger.error "DEQUEUED #{length state}"
    result
  end

  def handle_cast({:enqueue, item}, state) do
    {:noreply, [item|state]}
  end
end
