class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # This method defines the movie table, so when we want the order to
  # be different, or for some movies to not show, those changes will
  # be made here. This function is called everytime the movies are to
  # be listed.
  def index
	
    @movies = Movie.all # Get all movies inside an instance variable
    @all_ratings =  ['G','PG','PG-13','R', 'NC-17'] # Ratings
    @rating_filter = {} # Create a hash for what ratings are checked
	
	# Get the remembered settings, first check that one of the session
	# params exist
	if (session[:ratings] != nil or session[:order] != nil)
		# Check that one of the params is empty
		if (params[:order] == nil or (params[:ratings] == nil))
			# Remember :order?
			if (params[:order] == nil and session[:order] != nil)
			  params[:order] = session[:order]
			end
			# Remember :ratings?
			if (params[:ratings] == nil and session[:order] != nil)
				params[:ratings] = session[:ratings]
			end
			# Reload with wanted parameters
			redirect_to movies_path(:order => params[:order],
				:ratings => params[:ratings]) 
		end
	end
	
	# Set the rating_filter hash depending on what :ratings is, which
	# will only contain elements for every checked rating
	@all_ratings.each { |rating|
		if params[:ratings] != nil
			if params[:ratings].has_key?(rating)
				@rating_filter[rating] = true
			else
				@rating_filter[rating] = false
			end
		end
    }
	
	# Remove movies with ratings that are unchecked
	if (params[:ratings] != nil)
		@movies = @movies.find_all{ |movie| @rating_filter.has_key?(movie.rating) and @rating_filter[movie.rating] == true }
	end
	
	# If the parameter :order matches 'title', sort movies by title
	if (params[:order] == 'title')
		@movies = @movies.sort_by{ |movie| movie.title }
	elsif (params[:order] == 'date')
		@movies = @movies.sort_by{ |movie| movie.release_date.to_s }
	end
	
	# Save values to session
	session[:order] = params[:order]
    session[:ratings] = params[:ratings]
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
