CfTimeclockRails::Application.routes.draw do
  get 'views/main' => 'welcome#main'
  root 'welcome#index'
end
