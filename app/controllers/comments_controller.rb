class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authorize_comment_owner!, only: [:edit, :update, :destroy]


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

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment.property, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    property = @comment.property
    @comment.destroy
    redirect_to property, notice: 'Comment was successfully deleted.'
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def authorize_comment_owner!
    unless @comment.user == current_user
      redirect_to @comment.property, alert: 'You are not authorized to perform this action.'
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end