class Mypage::TechniquesController < Mypage::BaseController
  def index
    @techniques = current_user.techniques
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
