class User < ApplicationRecord
  after_create :copy_presets

  has_many :techniques, dependent: :destroy
  has_many :charts, dependent: :destroy
  # ロジック記述が楽になるので以下のリレーションを定義するが、nodesテーブルはuser_idカラムをFKとして持っていない。
  # (chartsテーブルを通じて間接的にusersテーブルと結ばれている)
  has_many :nodes, through: :charts

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
          :omniauthable, omniauth_providers: [ :google_oauth2 ]

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

  private

  def copy_presets
    ApplicationRecord.transaction do
      TechniquePreset.find_each do |tp|
        self.techniques.create!(
          technique_preset: tp,
          name_ja: tp.name_ja,
          name_en: tp.name_en,
          category: tp.category
        )
      end

      # TODO: i18n対応、keyカラム追加する？
      top = self.techniques.find_or_create_by!(
        name_ja: "トップポジション",
        name_en: "Top Position"
      )

      bottom = self.techniques.find_or_create_by!(
        name_ja: "ボトムポジション",
        name_en: "Bottom Position"
      )

      # 一意制約に抵触しない命名
      chart = self.charts.create!(
        name: "preset_#{Time.current}"
      )

      [ top, bottom ].each do |technique|
        chart.nodes.create!(
          chart: chart,
          technique: technique,
          ancestry: "/"
        )
      end
    end
  end
end
