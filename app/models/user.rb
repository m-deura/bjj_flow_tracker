class User < ApplicationRecord
  after_create :copy_presets

  has_many :techniques, dependent: :destroy
  has_many :charts, dependent: :destroy
  # ロジック記述が楽になるので以下のリレーションを定義するが、nodesテーブルはuser_idカラムをFKとして持っていない。
  # (chartsテーブルを通じて間接的にusersテーブルと結ばれている)
  has_many :nodes, through: :charts

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :validatable,

  devise :database_authenticatable, :rememberable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :provider, :uid, :name, :email, presence: true
  validates :email, uniqueness: true
  validates :provider, uniqueness: { scope: :uid }

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # if you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.create_guest!
    create!(
      provider: "guest",
      uid: SecureRandom.uuid,
      email: "guest+#{SecureRandom.uuid}@example.com",
      password: SecureRandom.base58(20),
      name: "Guest",
      image: "icon.svg"
    )
  end

  def guest?
    provider == "guest"
  end

  private

  def copy_presets
    ActiveRecord::Base.transaction do
      TechniquePreset.find_each do |tp|
        self.techniques.create!(
          technique_preset: tp,
          name_ja: tp.name_ja,
          name_en: tp.name_en,
          category: tp.category
        )
      end

      # 初回チャートをプリセットから作る（プリセットが無い場合はスキップ）
      if (cp = ChartPreset.first)
        ApplyChartPreset.call(
          user: self,
          chart_preset: cp,
          chart_name: "preset_#{Time.current.strftime('%Y%m%d-%H%M%S')}"
        )
      else
      # フォールバック：プリセットが無ければ空チャートだけ作る
      charts.find_or_create_by!(name: "empty_#{Time.current.strftime('%Y%m%d-%H%M%S')}")
      end
    end
  end
end
