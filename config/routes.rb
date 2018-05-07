Rails.application.routes.draw do
  get :health_check, to: 'health#check', via: :get

  namespace :api do
    get :geocode, to: 'location#geocode', via: :get
    post 'distance/from_city', to: 'location#distance_from_city', via: :post
  end
end
