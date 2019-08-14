Rails.application.routes.draw do
  get '/mapkit_token', to: 'mapkit_token/mapkit_token#show'
end
