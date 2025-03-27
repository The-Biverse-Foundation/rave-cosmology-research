Rails.application.routes.draw do
  root "fixed_stars#home"
  get "fixed_stars/:id", to: "fixed_stars#show", as: "fixed_star"
end
