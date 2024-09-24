class CommentsController < ApplicationController
  before_action :authenticate_user!#, except: [:index, :show]

  def create
    @property = Property.find(params[:property_id])
    @comment = @property.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to property_path(@property), notice: "Comment added!"
    else
      redirect_to property_path(@property), alert: "Comment could not be added."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end