require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def board
    session[:grid] = ('A'..'Z').to_a.sample(10)
    @grid = session[:grid]
  end

  def score
    url = "https://wagon-dictionary.herokuapp.com/#{params['attempt']}"
    response_serialized = URI.open(url).read
    response = JSON.parse(response_serialized)
    included_check = true
    @grid = session[:grid]
    @total_score = session[:tscore] || 0
    params['attempt'].each_char do |char|
      included_check &&= @grid.include?(char.upcase)
      @grid.delete_at(@grid.index(char.upcase)) unless @grid.index(char.upcase).nil?
    end
    if response['found'] == false
      @result = { message: "Sorry, but #{params['attempt']} is not an english word", score: 0 }
    elsif included_check == false
      @result = { message: "Sorry, but #{params['attempt']} is not in the grid", score: 0 }
    else
      @result = { message: "#{params['attempt']} is an english word",
                  score: params['attempt'].size }
      tscore = @total_score
      tscore += @result[:score]
      session[:tscore] = tscore
      @total_score = session[:tscore] || 0
    end
  end
end
