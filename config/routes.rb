Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users
  
  # Cabinets (onboarding)
  resources :cabinets, only: [:new, :create, :show, :edit, :update]
  
  # Patients
  resources :patients
  
  # Rendez-vous
  resources :appointments do
    collection do
      get :calendar
      get :calendar_view  # Nouvelle vue avec FullCalendar
      get :events_json    # API JSON pour FullCalendar
      get :waiting_list
    end
    member do
      patch :change_status
      patch :update_date  # Pour le drag & drop
    end
    # Consultations (comptes rendus) - uniquement pour les médecins
    resources :consultations, only: [:show, :new, :create, :edit, :update, :destroy]
  end
  
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
