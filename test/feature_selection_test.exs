defmodule FeatureSelectionTest do
  use ExUnit.Case
  doctest FeatureSelection

  require Logger

  test "selecting feature in Evaluation" do
    Logger.debug "selecting feature in Evaluation"
    iris = UCIDataLoader.load_iris()
    select = ["1", "1", "0", "1"]
    iris |> Evaluation.selecting(select) |> IO.inspect
  end

  test "test number to bit string" do
    Logger.debug "test number to bit string"
    Search.to_bitstring(15, 4) |> IO.inspect
  end
end
