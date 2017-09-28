defmodule Filter do
  def frac(x, y) do
    x / y
  end

  def transpose(datasets) do
    new_data =
      0..datasets.length-1
      |> Enum.map(fn(i) ->
        datasets.data
        |> Enum.map(&(&1 |> Enum.at(i)))
      end)
    %UCIDataLoader {
      data:            new_data,
      target_all_name: datasets.target_all_name,
      target_names:    datasets.target_names,
      length:          datasets.amount,
      amount:          datasets.length,
      cluster_num:     datasets.cluster_num,
      each_amount:     datasets.each_amount,
    }
  end

  def each_feature_distance(datasets) do
    t_datasets = datasets |> transpose
    0..t_datasets.amount-1 |> Enum.map(fn(i) ->
      0..t_datasets.amount-1 |> Enum.map(fn(j) ->
        if i != j do
          # IO.inspect [i,j]
          Enum.zip(
            t_datasets.data |> Enum.at(i),
            t_datasets.data |> Enum.at(j)
          )
          |> Enum.map(fn({x,y})->
            x-y |> :math.pow(2)
          end)
          |> Enum.sum
        else
          nil
        end
      end)#  |> Enum.filter(&(&1 != nil))
    end)
  end

  def almost_near(datasets, reduct_per) do
    distance = datasets |> each_feature_distance

    mean = distance |> List.flatten |> Enum.filter(&(&1 != nil)) |> Enum.sum |> frac((distance |> Enum.count) -1)
    threshold = mean * reduct_per

    # 0..datasets.length-2 |> Enum.map(fn(i) ->
    #   0..datasets.length-i-2 |> Enum.map(fn(j) ->
    0..datasets.length-1 |> Enum.map(fn(i) ->
      0..datasets.length-1 |> Enum.map(fn(j) ->
        tmp = distance |> Enum.at(i) |> Enum.at(j)
        if i != j and tmp != nil and tmp < threshold do
          [i, j]
        end
      end)
    end)
    |> List.flatten
    |> Enum.filter(&(&1 != nil))
  end

  def most_near(datasets) do
    distance = datasets |> each_feature_distance |> IO.inspect

    min_dis   = distance |> Enum.map(&(&1 |> Enum.min)) |> Enum.min

    0..datasets.length-1 |> Enum.map(fn(i) ->
      0..datasets.length-1 |> Enum.map(fn(j) ->
        tmp = distance |> Enum.at(i) |> Enum.at(j)
        if i != j and tmp == min_dis do
          [i, j]
        end
      end)
    end)
    |> List.flatten
    |> Enum.filter(&(&1 != nil))
  end

  def count_up(lst, length) do
    # IO.puts "count up"
    IO.inspect lst
    0..length-1 |> Enum.map(fn(i) ->
      lst |> Enum.filter(&(&1 == i)) |> Enum.count
    end)
    |> Enum.map(&(round(&1/2)))
  end

  def selection(datasets, reduct_per) do
    most_near(datasets)#   |> IO.inspect
    almost_near(datasets, reduct_per) |> count_up(datasets.length) |> IO.inspect
    {:ok, "finished"}
  end
end

defmodule Wrapper do
  @test_num 1598
  def accuracy(selected_datasets) do
    selected_datasets
    |> get_test_data(@test_num)
    |> Enum.map(
      fn({test_data, test_cluster}) ->
        {selected_datasets, test_data} |> knn |> elem(1) == test_cluster
      end
    )
    |> Enum.filter(&(&1 == true))
    |> Enum.count
    |> frac(@test_num)
  end

  defp mult(x, y) do
    x * y
  end
  defp frac(x, y) do
    x / y
  end
  def get_test_data(datasets, n) do
    1..n
    |> Enum.map(
      fn(_) ->
        at = :rand.uniform(datasets.amount)-1
        {datasets.data |> Enum.at(at), datasets.target_all_name |> Enum.at(at)}
      end
    )
  end

  def knn({datasets, data}) do
    Enum.zip(datasets.data, datasets.target_all_name)
    |> Enum.map(fn({each_data,name}) ->
      # IO.inspect data
      [dist(each_data, data), name]
    end)
    |> Enum.sort
    |> vote(3,datasets.target_names)
  end

  defp vote(sorted, k, target_names) do
    vote_names = 0..k-1
                 |> Enum.map(&(sorted |> Enum.at(&1) |> Enum.at(1)))
                 # |> Enum.map(&(counter = counter |> Map.update(&1,1,fn x -> x+1 end)))
    target_names
    |> Enum.map(
      fn(tname) ->
        {
          (vote_names
          |> Enum.filter(&(&1 == tname))
          |> Enum.count), tname
        }
      end)
      |> Enum.max # TODO: More check detaily
  end

  defp dist(x, y) do
    # IO.inspect x
    # IO.inspect y
    Enum.zip(x,y)
    |> Enum.map(&((&1 |> elem(0)) - (&1 |> elem(1))))
    |> Enum.map(&(&1 |> :math.pow(2)))
    |> Enum.sum
    |> :math.sqrt
  end
end

