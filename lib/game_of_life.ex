defmodule GameOfLife do
  @doc """
  Tests if each of the elements of the left argument appears as an element of the right argument.

  iex(1)> matrix = Nx.iota({9}) |> Nx.reshape({3, 3})
  iex(2)> set = [1, 2, 3, 4, 7]
  iex(6)> GameOfLife.member_of(matrix, set)
  #Nx.Tensor<
    u8[3][3]
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 1, 0]
    ]
  >
  """
  def member_of(left, right) do
    Enum.reduce(right, Nx.broadcast(Nx.tensor(0), Nx.shape(left)), fn value, acc ->
      mask = Nx.equal(left, value)
      Nx.logical_or(acc, mask)
    end)
  end
end
