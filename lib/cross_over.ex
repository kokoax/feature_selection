defmodule CrossOver do
  require Logger
  require MyMap

  def uniform(parent1, parent2, uniform_binary) do
    IO.inspect parent1, parent2, uniform_binary
    false
  end

  def crossover(parents, point) do
    Logger.debug "Cross Over Funtion"

    parents
    |> split(point)
    |> generate_children
  end
  def split({parent1, parent2}, points) do
    splited1 = parent1
               |> split_parent(points)
    splited2 = parent2
               |> split_parent(points)
    {splited1, splited2}
  end

  def ajust_split(next, prev) do
    if prev == nil do
      next
    else
      next
      |> Enum.slice((prev |> Enum.count), (next |> Enum.count))
    end
  end

  def split_parent(parent, points) do
    Logger.debug "Split Parent Function"
    tmp = 0..(points |> Enum.count)-1
          |> Enum.map(
            fn(point_i) ->
              parent
              |> Enum.split(points |> Enum.at(point_i))
              |> elem(0)
            end
          )
    tmp ++ [parent]
    |> Enum.reverse
    |> MyMap.second_map(&(ajust_split(&1, &2)))
    |> Enum.reverse
  end

  def generate_children({splited1, splited2}) do
    {child1,child2} =
      0..(splited1 |> Enum.count)-1
      |> Enum.map(
        fn(i) ->
          if rem(i,2) == 1 do
            {splited1 |> Enum.at(i),
              splited2 |> Enum.at(i)}
          else
            {splited2 |> Enum.at(i),
              splited1 |> Enum.at(i)}
          end
        end
      )
      |> Enum.unzip

    [child1|>Enum.concat,child2|>Enum.concat]
  end

end

defmodule CrossOver.DominanceMulti do
  require Logger

  # require Evaluation
  require Wrapper
  require MyMap

  def check_evaluation([child1,child2], {parent1,parent2}, datasets) do
    [child1_eval,child2_eval,parent1_eval,parent2_eval] =
      [child1,child2,parent1,parent2]
      |> Enum.map(
        fn(feature) ->
          Task.async(
            fn ->
              feature |> Wrapper.cluster_distance(datasets)
            end)
        end)
        |> Enum.map(&(&1 |> Task.await()))
        # child1_eval  = child1  |> Wrapper.cluster_distance(datasets)
        # child2_eval  = child2  |> Wrapper.cluster_distance(datasets)
        # parent1_eval = parent1 |> Wrapper.cluster_distance(datasets)
        # parent2_eval = parent2 |> Wrapper.cluster_distance(datasets)
    [
      if child1_eval <= parent1_eval do
        Logger.debug "Child1 is good more than parent1"
        child1
      else
        parent1
      end,
      if child2_eval <= parent2_eval do
        Logger.debug "Child2 is good more than parent2"
        child2
      else
        parent2
      end
    ]
  end

  def crossover(genomes, datasets, point_num, probably) do
    Logger.debug "Dominance Multi Cross Over Function"
    genomes
    |> MyMap.two_map(
      fn(parent1, parent2) ->
        Task.async(
          fn ->
            parents = {parent1, parent2}
            if probably > :rand.uniform do
              points = 1..point_num
                       |> Enum.map(fn(_) -> (:rand.uniform(parent1 |> Enum.count)-1) end)
                       |> Enum.sort
                       parents
                       |> CrossOver.crossover(points)
                       |> check_evaluation(parents, datasets)
            else
              Logger.debug "It Didn't Hit Crossover"
              # {parent1, parent2} = parents
              [parent1, parent2]
            end
          end)
      end)
      |> Enum.map(&(&1 |> Task.await()))
      |> Enum.concat
  end
end

defmodule CrossOver.MultiPoint do
  require Logger

  require CrossOver
  require MyMap

  def multi_point(genomes, point_num, probably) do
    Logger.debug "Multi Point Cross Over Function"
    genomes
    |> MyMap.two_map(
      fn(parent1, parent2) ->
        Task.async(
          fn ->
            if probably > :rand.uniform do
              points =
                1..point_num
                |> Enum.map(fn(_) -> (:rand.uniform(parent1 |> Enum.count)-1) end)
                |> Enum.sort

                {parent1, parent2}
                |> CrossOver.crossover(points)
            else
              Logger.debug "It Didn't Hit Crossover"
              # {parent1, parent2} = parents
              [parent1, parent2]
            end
          end)
      end)
      |> Enum.map(&(&1 |> Task.await()))
      |> Enum.concat
  end
end

defmodule CrossOver.OnePoint do
  require Logger

  require CrossOver

  def one_point(parents) do
    point = :rand.uniform((parents |> elem(0) |> Enum.count)-1)
    parents
    |> CrossOver.crossover([point])
  end
end

