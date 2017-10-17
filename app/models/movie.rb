class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(search_string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      tmdbMovies=Tmdb::Movie.find(search_string)
      movies = []
      if tmdbMovies
        tmdbMovies.each do |movie|
          rating = Movie.get_rating(movie.id)
          if rating != "G" and rating != "PG" and rating != "PG-13" and rating != "NC-17" and rating != "R"
            rating = "NR"
          end
          # puts "Rating is: "+rating
          movies.append({:tmdb_id => movie.id, :title => movie.title, :rating => rating, :release_date => movie.release_date})
          # puts "Rating is: "+rating
        end
      end
      return movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
    movie_detail = Tmdb::Movie.detail(id)
    movie = {:title => movie_detail["title"], :rating => Movie.get_rating(id), :description => movie_detail["overview"], :release_date => movie_detail["release_date"]}
    Movie.create(movie)
  end
  
  def self.get_rating(id)
    rating = "NR"
    Tmdb::Movie.releases(id)["countries"].each do |country|
      if country["iso_3166_1"] == "US"
        rating = country["certification"]
        # puts rating
      end
    end
    return rating
  end

end