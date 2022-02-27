Rails.application.routes.draw do
  resources :companies do
    collection do
      get :search_in_companies_house
    end
  end
  root 'companies#search_in_companies_house'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
