class Mypage::NodesController < Mypage::BaseController
  def new
  end

  def create
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @technique = @node.technique
  end

  def update
  end

  def destroy
  end
end
