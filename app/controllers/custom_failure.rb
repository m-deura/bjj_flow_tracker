class CustomFailure < Devise::FailureApp
  private
    # ログインしていない状態で要ログインページにアクセスした際のリダイレクト先指定
    def redirect_url
      root_path
    end
end
