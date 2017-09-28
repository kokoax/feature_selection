defmodule GeneticClustering do
  require Logger

  require Wrapper
  require Filter
  require CrossOver
  require Selection
  require Mutation

  @generation 10000

  # @children_num 10
  @children_num 20

  @ranking_parameter [3,3,3,2,2,1,1,1,1,1,1,1]

  @crossover_point 2
  # @crossover_point 3
  # @crossover_point 5
  # @crossover_point 10

  @crossover_probably 0.95

  # @mutation_probably  0.01   # 1%
  # @mutation_probably  0.007  # 0.7%
  # 1 / 150 := 0.00667 = 0.667%
  # 0.5%は、irisだと、それぞれの染色体に対して 塩基が0~1個の突然変異ぐらいの値
  @mutation_probably  0.005  # 0.5% この辺が良い気がする 上は安定しなくて 下だと、局所解に速攻で突っ込む
  # @mutation_probably  0.001  # 0.1%
  # @mutation_probably  0.0001 # 0.01%

  def generate_first_genomes(datasets) do
    1..@children_num
    |> Enum.map(fn(_) ->
      :rand.uniform(round(:math.pow(2, datasets.length))-1)
    end)
    |> IO.inspect
    |> Enum.map(&(&1 |> to_bitstring(datasets.length)))
  end

  def get_children(genomes, eval, num, datasets) do
    Logger.debug "Get Children Function"


    child_genomes =
      genomes
      # |> Selection.roulette(eval)
      |> Selection.ranking(eval, @ranking_parameter)
      |> Enum.take_random(@children_num)

    child_datasets = genomes |> Enum.map(&(datasets |> selecting(&1)))

    child_genomes
    |> CrossOver.MultiPoint.multi_point(@crossover_point, @crossover_probably)
    |> Mutation.binary(@mutation_probably)
  end

  def loop(_, _, num \\ 0)

  def loop(_, _, @generation) do
    nil
  end

  def loop(genomes, datasets, num) do
    eval =
      genomes
      |> Enum.map(&(selecting(datasets, &1) |> Wrapper.accuracy))
      |> Enum.map(&(&1 |> IO.inspect))

    # if eval |> Enum.filter(&(&1 > 0.75)) |> Enum.count >= 3 do
    # if eval |> Enum.any?(&(&1 == 0)) do
    if eval |> Enum.all?(&(&1 > 0.75)) do
      [eval, genomes]
    else
      children = get_children(genomes, eval, num, datasets)
      loop(children, datasets, num+1)
    end
  end

  def generation_loop(datasets) do
    genomes = datasets |> generate_first_genomes
    genomes |> IO.inspect
    :timer.tc(fn -> loop(genomes, datasets) end) |> IO.inspect
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

  def selecting_r(data, select, attr \\ 0)

  def selecting_r(data, ["1"], _) do
    data |> Enum.map(&(&1 |> Enum.at(0)))
  end

  def selecting_r(data, ["0"], _) do
    data |> Enum.map(fn(_) -> nil end)
  end

  def selecting_r(data, [select|tail], attr) do
    tmp = selecting_r(data, tail, attr+1)
    if select == "1" do
      data
      |> Enum.map(&(&1 |> Enum.at(attr)))
      |> Enum.zip(tmp)
      |> Enum.map(fn({x,y}) -> [x,y] |> List.flatten end)
    else
      data
      |> Enum.map(fn(_) -> nil end)
      |> Enum.zip(tmp)
      |> Enum.map(fn({x,y}) -> [x,y] |> List.flatten end)
    end
  end

  def selecting(datasets, select) do
    data = selecting_r(datasets.data, select) |> Enum.map(fn(selected) -> selected |> Enum.filter(&(&1 != nil)) end)

    length = data |> Enum.at(0) |> Enum.count
    %UCIDataLoader {
      data:            data,
      target_all_name: datasets.target_all_name,
      target_names:    datasets.target_names,
      length:          length,
      amount:          datasets.amount,
      cluster_num:     datasets.cluster_num,
      each_amount:     datasets.each_amount,
    }
  end
end

