MapkitToken::Engine.routes.draw do
  get '/mapkit_token', to: 'mapkit_token#show', as: 'mapkit_token'
end
