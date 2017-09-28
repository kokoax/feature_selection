defmodule Search do
  def search(datasets) do
    1..trunc(:math.pow(2, datasets.length)-1)
    |> Enum.map(fn(select) ->
      datasets |> Evaluation.accuracy(select |> to_bitstring(datasets.length))
    end)
  end
  def to_bitstring(_, 0) do
    []
  end
  def to_bitstring(select, num) do
    [to_bitstring(trunc(select/2), num-1),
     if rem(select,2) == 1 and select != 0 do
       "1"
     else
       "0"
     end] |> List.flatten
  end
end

defmodule FeatureSelection do
  def main() do
    UCIDataLoader.load_wine_quality_red # |> GeneticClustering.generation_loop
    # UCIDataLoader.load_wine_quality |> GeneticClustering.generation_loop
  end
end
