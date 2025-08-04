class User < ApplicationRecord
  after_create :copy_technique_presets

  has_many :techniques, dependent: :destroy
  has_many :charts, dependent: :destroy

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

  def copy_technique_presets
    TechniquePreset.find_each do |tp|
      self.techniques.create!(
        technique_preset: tp,
        name: tp.name_ja,
        category: tp.category
      )
    end
  end
end
