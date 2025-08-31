class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top; end

  def privacy; end

  def terms; end
end
