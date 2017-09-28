defmodule Selection do
  require Logger

  def roulette(genomes, evals) do
    genomes |> Roulette.selection(evals)
  end
  def expected_value(genomes, evals, genome_num) do
    genomes |> ExpectedValue.selection(evals, genome_num)
  end
  def ranking(genomes, evals, rank) do
    genomes |> Ranking.selection(evals, rank)
  end
  def tournament() do
    false
  end
  def elitist_preserving() do
    false
  end
end

defmodule Ranking do
  require Logger

  def selection(genomes, evals, rank) do
    Logger.debug "Ranking Selection"
    # Genomes sort by evals
    {genomes,_} = Enum.zip(genomes, evals)
        # |> Enum.sort(fn(i, j) -> i > j end)
        # |> Enum.sort_by(fn(item) -> item end)
        # |> Enum.sort_by(fn({_,eval}) -> eval end, &(&1 > &2))
        # |> Enum.sort_by(fn({_,eval}) -> eval end)
        |> Enum.sort(fn({_,e1}, {_,e2}) -> e1 > e2 end)
        |> Enum.unzip

    Enum.zip(rank,genomes)
      |> Enum.flat_map(
        fn({num,genome}) ->
          1..num |> Enum.map(fn(_) -> genome end)
        end
      )
  end
end

defmodule ExpectedValue do
  def selection(genomes, eval, genome_num) do
    genomes |> Enum.map(&(&1 |> Enum.at(0)))
    eval
      |> Enum.map(&(round(genome_num*(&1 / (eval |> Enum.sum)))))
  end
end

defmodule Roulette do
  require Logger

  def roulette([_|next], _, _, num) when next == [] do
    num
  end
  def roulette([eval|next], probablity_sum, target, num) do
    if probablity_sum+eval > target do
      num
    else
      next |> roulette(probablity_sum+eval, target, num+1)
    end
  end
  def selection(genomes, evals) do
    Logger.debug "Routlette Selection"

    0..(genomes |> Enum.count)-1
    |> Enum.map(fn(_) ->
      evals
      |> Enum.map(&(&1 / (evals |> Enum.sum)))
      |> roulette(0, :rand.uniform, 0)
    end)
    |> Enum.map(&(genomes |> Enum.at(&1)))
  end
end

