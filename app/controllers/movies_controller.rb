class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Get list of all ratings
    all_ratings
  
    logger.debug("*** params ***#{params} \n ")
    
    # Filtering
    # params[:ratings] == {"PG-13"=>"on"}
    ratings=nil
    if params[:commit]=="Refresh"
      if params[:ratings] == nil
        flash[:ratings] = nil
      end
    end

    # Refresh selected
    @ratings_checked=(params[:ratings] == nil ? flash[:ratings] : params[:ratings])
    if @ratings_checked==nil; @ratings_checked={}; end
    ratings = (@ratings_checked=={} ? nil : @ratings_checked.keys)
    flash[:ratings]=@ratings_checked
    
    # Sorting
    @sort=(params[:sort]==nil ? flash[:sort] : params[:sort])
    if @sort==nil 
      # Refence to model
      @movies=Movie; 
    else
      @movies = Movie.order("#{@sort} ASC")
    end
    flash[:sort]=@sort
    
    # Filter by ratings
    if ratings!=nil
      @movies = @movies.where("rating IN (?)",ratings)
    end

    # Array with all movies selected 
    @movies = @movies.all
    
    logger.debug("*** checked = #{@ratings_checked}***")
  end
  
  def all_ratings
    # [{"rating" => "G"}]..
    @all_ratings = []
    Movie.select("DISTINCT rating").each { |el| @all_ratings.push(el) }
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
