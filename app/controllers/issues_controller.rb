class IssuesController < ApplicationController
  before_action :find_issue, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @issues = Issue.select('*, (select sum(direction) from votes where issue_id = issues.id) as total')
   .order('total desc NULLS LAST, created_at desc')
   if user_signed_in?
    @issues_marker = Issue.where(city: current_user.city).where.not(latitude: nil, longitude: nil)
    else
    @issues_marker = Issue.where.not(latitude: nil, longitude: nil)
  end

    @markers = @issues_marker.map do |issue|
      {
        lat: issue.latitude,
        lng: issue.longitude,
        infoWindow: { content: render_to_string(partial: "/issues/map_info_window", locals: { issue: issue }), class: "info-window" },
      }
    end
  end

  def show
    @comments = @issue.comments.order(created_at: :desc)
    @comment = Comment.new
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(issue_params)
    @issue.user = current_user
    if @issue.save
      @issue.city = Geocoder.search([@issue.latitude, @issue.longitude]).first.city
      response = JSON.parse(RestClient.get "http://www.mapquestapi.com/directions/v2/findlinkid?key=SUwY49iDvVUIUtWdWXnHLhP1v9etD2d3&lat=#{@issue.latitude}&lng=#{@issue.longitude}")
      @issue.link_id = response["link_id"]
      @issue.save
      redirect_to issue_path(@issue)
    else
      render :new
    end
  end

  def edit; end

  def update
  end

  def destroy
    @issue.destroy
    redirect_to issues_path
  end


  private

  def find_issue
    @issue = Issue.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(:title, :description, :solution, :address, :fix_status, :longitude, :latitude,  photos: [])
  end
end
