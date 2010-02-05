ActionController::Routing::Routes.draw do |map|
  map.filter 'locale'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.resources :users

  map.resource :session

  map.resources :documents, :as => '', :collection => {:sort => :post} do |documents|
    documents.resources :document_revisions, :as => 'revisions'
    documents.resources :comments
  end

  map.root :controller => 'documents', :action => 'index'
end
