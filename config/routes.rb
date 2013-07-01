CfTimeclockRails::Application.routes.draw do
  root 'welcome#index'
  get '*path' => "welcome#index"
end
