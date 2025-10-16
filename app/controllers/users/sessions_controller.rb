class Users::SessionsController < Devise::SessionsController
  def guest_sign_in
    user = find_or_create_guest!

    flash[:notice] = t("defaults.flash_messages.guest_signed_in")
    flash[:alert] = t("defaults.flash_messages.guest_notice")
    # devise の after_sign_in_path_for に従う
    sign_in_and_redirect user, event: :authentication
  end

  private

  def current_guest_user
    return unless (gid = session[:guest_user_id])
    @current_guest_user ||= User.find_by(id: gid, provider: "guest")
  end

  # 既存ゲストを再利用 or 新規発行
  def find_or_create_guest!
    if user = current_guest_user
      # update_atを現在の時刻でアップデートして、ゲストユーザー定期削除スクリプトにおける削除期日を延長。
      user.touch
      user
    else
      user = User.create_guest!
      session[:guest_user_id] = user.id
      user
    end
  end
end
