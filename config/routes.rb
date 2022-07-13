# frozen_string_literal: true

Rails.application.routes.draw do
  post '/events', to: 'events#save'
  get '/reports/:employee_id/:from/:to' => 'reports#get'
end
