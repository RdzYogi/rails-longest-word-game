require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def board
    session[:grid] = ('A'..'Z').to_a.sample(10)
    @grid = session[:grid]
    session[:tscore] = 0 if params["refresh"] == "true"
  end

  def score
    response = check_word(params['attempt'])
    @grid = session[:grid]
    @total_score = session[:tscore] || 0
    included_check = check_included_grid(params['attempt'], @grid)
    if response['found'] == false
      @result = { message: "Sorry, but #{params['attempt']} is not an english word", score: 0 }
    elsif included_check == false
      @result = { message: "Sorry, but #{params['attempt']} is not in the grid", score: 0 }
    else
      @result = { message: "#{params['attempt']} is an english word",
                  score: params['attempt'].size }
      @total_score = update_score(@total_score, @result[:score])
    end
  end

  private

  def update_score(oldtscore, newscore)
    tscore = oldtscore + newscore
    session[:tscore] = tscore
    tscore
  end

  def check_included_grid(word, grid)
    included_check = true
    word.each_char do |char|
      included_check &&= grid.include?(char.upcase)
      grid.delete_at(grid.index(char.upcase)) unless grid.index(char.upcase).nil?
    end
    included_check
  end

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response_serialized = URI.open(url).read
    JSON.parse(response_serialized)
  end
end
