Rails.application.routes.draw do
 
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  devise_for :users
 # devise_for :users
  resources :tagoverlaps
  resources :tagexcepts
  resources :sources do
    resources :infos
  end  
  resources :pages
  resources :sourcehtmls

  root 'pages#index'
  get 'loadnews', to: 'pages#load'
  get 'analyze', to: 'pages#analyze'
  get 'category/:category', to: 'pages#index', as: :category
  get 'ss', to: 'pages#index'
  get 'data', to: 'pages#index', as: :data
  get 'atags', to: 'pages#atags'
  get 'tag_cloud', to: 'pages#tag_cloud'
  get 'tags/:tag', to: 'pages#index', as: :tag
  # get 'data/:data', to: 'pages#index', as: :data
  get 'info', to: 'infos#info'
  get 'remove_tags', to: 'pages#rtags'
  get 'tagexport', to:   'pages#tagexport'
  get 'tagimport', to:   'pages#tagimport'
  get 'search_tags', to: 'pages#search_tags'
  post 'search_tags', to: 'pages#index'
  get 'redis', to: 'pages#redis'
  get 'rss', to: 'pages#rss'
  get 'infoday', to: 'infos#infoday'
  get 'infoday1', to: 'infos#infoday1'
  get 'infotoday', to: 'infos#infotoday'
  get 'html', to: 'sourcehtmls#html'
  get 'tmp', to: 'pages#tmp'
  get 'sourceexport', to:   'sources#sourceexport'
  get 'sourceimport', to:   'sources#sourceimport'
end
