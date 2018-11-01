require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = Array.new(12) { ('A'..'Z').to_a.sample }
  end

  def build_hash(string)
    string.downcase.chars.reduce(Hash.new(0)) do |hash, letter|
      hash[letter] += 1
      hash
    end
  end

  def score
    @word = params[:word]
    length = @word.length
    @grid = params[:grid]
    freq_of_attempt = build_hash(@word)
    freq_of_grid = build_hash(@grid)
    contains = freq_of_attempt.all? { |key, value| freq_of_grid[key] >= value }

    if contains
      filepath = "https://wagon-dictionary.herokuapp.com/#{@word}"
      serialized_word = open(filepath).read
      word_check = JSON.parse(serialized_word)
      if word_check['found']
        @result = "The word is valid according to the grid and is an English word"
        length = @word.length
        @score = length * length
      else
        @result = "The word is valid according to the grid, but is not a valid English word"
        @score = 0
      end
    else
      @result = "The word is valid according to the grid and is an English word"
      @score = 0
    end
    session[:score].present? ? session[:score] += @score : session[:score] = @score
    @total_score = session[:score]
  end
end
