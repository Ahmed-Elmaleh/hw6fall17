require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
  it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    ##########################################
    it 'should show an error message if the user entered an invalid search' do
      fake_results = [double('Movie1'), double('Movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(flash[:notice]).to eq('Invalid search term')
    end
    it 'should show the user if no results were found in TMDb' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Test'}
      expect(flash[:notice]).to eq('No matching movies were found on TMDb')
    end
    it 'should redirect to the home page when the search is invalid' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ""}
      expect(response).to redirect_to("/movies")
    end 
    it 'should redirect to the home page when there are no movies found' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => "Ted"}
      expect(response).to redirect_to("/movies")
    end
  end
    
    
  describe 'adding a list of checked movies from TMDb' do
    context 'when checkboxes are not marked' do
      it 'should set a flash message alerting that no options were selected' do
        post :add_tmdb, {:tmdb_movies => nil}
        expect(flash[:notice]).to eq('No movies selected')
      end
    end
    context 'when checkboxes are marked' do
      it 'should call the Model method to add movies' do
        expect(Movie).to receive(:create_from_tmdb).with(550)
        post :add_tmdb, {:tmdb_movies => {550 => 1}}
      end
      
      it 'should send a list of TMDb IDs to the the RP homepage' do
        expect(Movie).to receive(:create_from_tmdb).with(96)
        expect(Movie).to receive(:create_from_tmdb).with(102)
        expect(Movie).to receive(:create_from_tmdb).with(140)
        post :add_tmdb, {:tmdb_movies => {96 => 1,102 => 1,140 => 1}}
        expect(response).to redirect_to("/movies")
      end
    end
    
    describe 'using Movie routes' do
      it 'should add movies to RP Db' do
        new_movie = {:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2000-1-1'}}
        expect(Movie).to receive(:create!).with(new_movie[:movie]).and_return(double(new_movie[:movie]))
        post :create, new_movie
        expect(flash[:notice]).to eq("Movie was successfully created.")
        expect(response).to redirect_to("/movies")
      end
      it 'should update movies in Db' do
        movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2000-1-1'}}
        movie = double(movie_params[:movie])
        expect(Movie).to receive(:find).with("1").and_return(movie)
        post :edit, movie_params
        expect(assigns(:movie)).to eq(movie)
        expect(Movie).to receive(:find).with("1").and_return(movie)
        expect(movie).to receive(:update_attributes!).with(movie_params[:movie]).and_return(nil)
        put :update, movie_params
        expect(flash[:notice]).to eq("Movie was successfully updated.")
      end 
      it 'should remove movies from Db' do
        movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2000-1-1'}}
        movie = double(movie_params[:movie])
        expect(Movie).to receive(:find).with("1").and_return(movie)
        expect(movie).to receive(:destroy)
        delete :destroy, movie_params
        expect(flash[:notice]).to eq("Movie 'Movie' deleted.")
        expect(response).to redirect_to("/movies")
      end
      it 'should show movie details' do
        movie_params = {:id=>1,:movie=>{:title => 'Movie', :rating => 'G', :description => 'Description', :release_date => '2000-1-1'}}
        movie = double(movie_params[:movie])
        expect(Movie).to receive(:find).with("1").and_return(movie)
        get :show, movie_params
        expect(assigns(:movie)).to eq(movie)
      end
    end
    
  end
end
