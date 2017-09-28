defmodule Mutation do
  require Logger
  def binary(genomes, probably) do
    genomes
    |> Enum.map(
      fn(chromosome) ->
        chromosome
        |> Enum.map(
          fn(color) ->
            if probably > :rand.uniform do
              Logger.debug "Hit Mutation"
              if color == "1" do "0" else "1" end
            else
              color
            end
          end)
      end)
  end
  def general(genomes, genome_length, probably) do
    # Logger.debug "General Mutation function"
    genomes
    |> Enum.map(
      fn(chromosome) ->
        chromosome
        |> Enum.map(
          fn(color) ->
            if probably > :rand.uniform do
              Logger.debug "Hit Mutation"
              :rand.uniform(genome_length)-1
            else
              color
            end
          end)
      end)
  end
  def inversions() do
    false
  end
  def displacement() do
    false
  end
  def duplication() do
    false
  end
  def deletion() do
    false
  end
end

