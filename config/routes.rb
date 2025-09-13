Rails.application.routes.draw do
  devise_for :users,
    controllers: { omniauth_callbacks: "users/omniauth_callbacks" },
    skip: [ :sessions ]

  devise_scope :user do
    # users/sign_in にアクセスされた場合、root_path にリダイレクト
    match "users/sign_in", to: redirect("/"), via: [ :get, :post ], as: :new_user_session
    delete "users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  LOCALES = Regexp.union(I18n.available_locales.map(&:to_s))
  scope "(:locale)", locale: LOCALES do
    # Defines the root path route ("/")
    root "pages#top"
    get "/:locale", to: "page#top"

    # Static pages
    get "privacy", to: "pages#privacy"
    # get "terms", to: "pages#terms"

    # My Pages
    namespace :mypage do
      root to: "dashboard#show"
      resources :techniques
      resources :charts, only: %i[show edit update] do
        resources :nodes, shallow: true, only: %i[new create edit update destroy]
      end
      resource :setting, only: %i[show edit update]
    end

    # API
    namespace :api do
      namespace :v1 do
        resources :charts, only: %i[index show]
      end
    end
  end
end
