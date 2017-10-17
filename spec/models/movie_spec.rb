
describe Movie do
  describe 'searching Tmdb by keyword' do
    
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Harry Potter')
        Movie.find_in_tmdb('Harry Potter')
      end
      it 'should return a list of movies' do
        fake_results = [double({:id => 96, :title => "Movie 1", :release_date => "1996-10-6"}),double({:id => 102, :title => "Movie 2", :release_date => "1999-31-12"})]
        allow(Tmdb::Movie).to receive(:find).and_return(fake_results)
        expect(Tmdb::Movie).to receive(:releases).with(96).and_return({"countries" =>[{"iso_3166_1" => "US", "certification" => "R"},{"iso_3166_1" => "BR", "certification" => "G"}
        ]})
        expect(Tmdb::Movie).to receive(:releases).with(102).and_return({"countries" =>[{"iso_3166_1" => "US", "certification" => "G"},{"iso_3166_1" => "BR", "certification" => "PG"}
        ]})
        movies = Movie.find_in_tmdb('gibberish')
        expect(movies[0]).to include({:tmdb_id => 96, :title => "Movie 1", :release_date => "1996-10-6", :rating => "R"})
        expect(movies[1]).to include({:tmdb_id => 102, :title => "Movie 2", :release_date => "1999-31-12", :rating => "G"})
      end
      it 'should add movies to RP' do
      expect(Tmdb::Movie).to receive(:detail).with(96).and_return({"title" => "Movie 1", "release_date" => "1996-10-6", "overview" => "overview"})
      expect(Movie).to receive(:get_rating).with(96).and_return("G")
      expect(Movie).to receive(:create).with({:title => "Movie 1", :release_date => "1996-10-6", :description => "overview", :rating => "G"})
      Movie.create_from_tmdb(96)
    end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError when key is invalid or missing' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('gibberish') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
end