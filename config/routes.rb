KnockKnock::Engine.routes.draw do
  post :auth_token, to: "auth_token#create"
end
