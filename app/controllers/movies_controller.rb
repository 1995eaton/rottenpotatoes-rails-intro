class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G', 'PG', 'PG-13', 'R']

    sort = params[:sort] || session[:sort]
    ratings = params[:ratings] || session[:ratings] || {}

    # if ratings == {}
    #   ratings = Hash[@all_ratings.map { |rating| [rating, "1"] }]
    # end

    @ratings = ratings

    @movies = case sort
    when "title"
      Movie.order(sort)
    when "release_date"
      Movie.order(sort)
    else
      Movie.all
    end

    if params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = ratings
      flash.keep
      redirect_to :sort => sort, :ratings => ratings
      return
    end

    if !params.key?(:sort) and params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      redirect_to :sort => sort, :ratings => ratings
      return
    end

    if ratings
      rsel = ratings.keys().select { |k| ratings[k] == "1" }
      session[:ratings] = ratings
      @movies = @movies.where({rating: rsel})
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
