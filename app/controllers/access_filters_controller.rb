class AccessFiltersController < ApplicationController
#  before_filter :require_admin

	def index
    @access_filters = AccessFilter.order(:position).all
	end

  def new
    @access_filter = AccessFilter.new
  end

  def create
    @access_filter = AccessFilter.new(params[:access_filter])
    if @access_filter.save
      redirect_to access_filters_path
    else
      render :new
    end
  end

  def edit
    @access_filter = AccessFilter.find(params[:id])
  end

  def update
    @access_filter = AccessFilter.find(params[:id])
    if @access_filter.update_attributes(params[:access_filter])
      redirect_to access_filters_path
    else
      render :edit
    end
  end

  def destroy
    @access_filter = AccessFilter.find(params[:id]) 
    @access_filter.destroy
    redirect_to access_filters_path
  end
end
