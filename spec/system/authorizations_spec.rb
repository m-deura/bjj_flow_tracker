require 'rails_helper'

RSpec.describe "Authorizations", type: :system do
  before do
    omniauth_login
    u1 = User.find_by(email: "tester1@example.com")
    u2 = create(:user)
  end

  describe "techniques" do
    it "他ユーザーが所有するテクニックが一覧に表示されない" do
    end
    it "他ユーザーが所有するテクニックの編集ページを表示できない" do
    end
  end

  describe "charts" do
    it "他ユーザーが所有するチャートが一覧に表示されない" do
    end
    it "他ユーザーが所有するチャートの描写用JSONを表示できない(APIが正しく返ってこない)" do
    end
    it "他ユーザーが所有するチャート詳細ページを表示できない" do
    end
    it "他ユーザーが所有するチャート編集ページを表示できない" do
    end
  end

  describe "nodes" do
    it "他ユーザーが所有するチャートのノード作成ページを表示できない" do
    end
    it "他ユーザーが所有するノード編集ページを表示できない" do
    end
  end
end
