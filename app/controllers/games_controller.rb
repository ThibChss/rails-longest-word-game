require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    vowels = 4.times.map { %w[A E I O U Y].sample }
    consonants = 5.times.map { %w[B C D F G H J K L M N P Q R S T V W X Z].sample }
    @letters = (vowels + consonants).shuffle
    @time = Time.now.utc
  end

  def score
    @word = params[:word].downcase.strip
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    words = JSON.parse(URI.open(url).read)
    @results = if words['found'] && check_word && count_time < 30
                 "Congratulation! #{@word.upcase} is a valid english word! Your score is #{@word.length} letters and your time is #{count_time} seconds"
               elsif words['found'] && count_time < 30
                 "The word #{@word.upcase} cannot be build with the letters..."
               elsif words['found'] == false
                 "Sorry but #{@word.upcase} does not seem to be a valid english word..."
               else
                 "You took #{count_time} seconds and were not fast enough..."
               end
  end

  def check_word
    letters = params[:letters].chars
    word = @word.strip.upcase.split('')
    word.each do |letter|
      return false if letters.index(letter).nil?

      letters.slice!(letters.index(letter))
    end
  end

  def count_time
    (Time.now.utc - params[:time].to_datetime).round
  end
end
