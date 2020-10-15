require 'open-uri'

class GamesController < ApplicationController
  VOWELS = %w(a e i o u y)

  def new
    # Generate grid with 5 vowels and 5 consonants, the same letter can be picked multiple times
    @grid = Array.new(5) { VOWELS.sample }
    @grid += Array.new(5) { (('a'..'z').to_a - VOWELS).sample }
    @grid.shuffle!
  end

  def score
    @attempt = params[:attempt].downcase.split(//)
    @grid = params[:grid].split(' ')

    # Check if letters are included in grid and if they are not used more times than the number of times they appear in the grid
    @letters_included = included?(@grid, @attempt)

    # Check if word is english
    @valid_english_word = english_word?(params[:attempt])

    # Calculate score and increment total score
    @score = update_score(@valid_english_word, @letters_included, params[:attempt])
  end

  private

  def included?(grid, attempt)
    attempt.all? { |letter| attempt.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_deserialized = open(url).read
    JSON.parse(word_deserialized)['found']
  end

  def update_score(valid_english_word, letters_included, attempt)
    # Initialize session with 0 points if no score
    session[:score] = 0 unless session[:score]

    # Score 0 points if the attempt is not valid, or score as many points as the attempt length
    score = valid_english_word && letters_included ? attempt.length : 0
    session[:score] += score
    return score
  end
end
