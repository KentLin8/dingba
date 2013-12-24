DingBa::Application.routes.draw do

  devise_for :users , :controllers => { :omniauth_callbacks => "omniauth_callbacks", confirmations: 'confirmations', :registrations => 'registrations' }

  devise_scope :user do
    match 'registrations/restaurant_new' => 'registrations#restaurant_new',      :via => 'get',  :as => 'res_new'
    match 'registrations/restaurant_create' => 'registrations#restaurant_create',:via => 'post', :as => 'res_create'
    match 'registrations/booker_new' => 'registrations#booker_new',              :via => 'get',  :as => 'booker_new'
    match 'registrations/booker_create' => 'registrations#booker_create',        :via => 'post', :as => 'booker_create'

    match 'sessions/restaurant_new' => 'sessions#restaurant_new',                :via => 'get',  :as => 'res_session_new'
    match 'sessions/booker_new' => 'sessions#booker_new',                        :via => 'get',  :as => 'booker_session_new'
    match 'sessions/create' => 'sessions#create',                                :via => 'post', :as => 'login_session'

    match '/users/auth/:provider' => 'omniauth_callbacks#passthru' ,             :via => 'get'

    get   'restaurant' => 'restaurant_manage#restaurant', :as => 'confirmation_getting_started'

  end

  root :to => 'home#index',                      :as => 'home'  #主要首頁,p1 不開放

  #==========================================================================
  # home controller
  #==========================================================================
  get  'home/index'
  get  'r/:id' => 'home#booking_restaurant'
  get  'home/get_condition'
  get  'home/notice_friend'
  get  'home/cancel_booking'

  post 'home/save_booking'
  post 'home/notice_friend'
  post 'home/save_cancel_booking'

  #==========================================================================
  # restaurant_manage controller
  #==========================================================================
  get  'restaurant_manage/restaurant_info',      :as => 'res_manage_info'
  post 'restaurant_manage/restaurant_info_save', :as => 'res_manage_info_save'

  get  'restaurant_manage/restaurant_image',     :as => 'res_manage_img'
  post 'restaurant_manage/upload_img',           :as => 'res_upload_img'

  get  'restaurant_manage/image_cover_save'      # TODO wait Front-end engineering
  get  'restaurant_manage/image_destroy'         # TODO wait Front-end engineering

  get  'restaurant_manage/supply_condition',     :as => 'res_manage_supply_condition'
  post 'restaurant_manage/condition_state_save'

  get  'restaurant_manage/supply_time',          :as => 'res_manage_supply_time'
  post 'restaurant_manage/supply_condition_save'

  get  'restaurant_manage/special_time'
  post 'restaurant_manage/special_create'
  get  'restaurant_manage/destroy_condition'

  get  'restaurant_manage/modify_booking'
  post 'restaurant_manage/modify_booking_save'
  post 'restaurant_manage/cancel_booking'

  get  'restaurant_manage/day_booking'
  get  'restaurant_manage/query_books_by_date'

  get  'restaurant_manage/book_create'           #test, it must to delete after prototype

  #==========================================================================
  # calendar controller
  #==========================================================================
  get 'calendar/restaurant_month',               :as => 'res_calendar_month'
  get 'calendar/restaurant_day'


  #==========================================================================
  # booker_manage controller
  #==========================================================================
  get  'booker_manage/index', :as => 'booker_manage_index'
  get  'booker_manage/booking_record'
  post 'booker_manage/feedback'


  # 暫時用來展示畫面的routes
  get "test/1", :to => 'viewtest#first'
  get "test/2", :to => 'viewtest#second'
  get "test/3", :to => 'viewtest#third'
  get "test/4", :to => 'viewtest#fourth'
  get 'test/5', :to => 'viewtest#fifth'
  get 'test/6', :to => 'viewtest#sixth'
  get 'test/7', :to => 'viewtest#seventh'
  get 'test/8', :to => 'viewtest#eighth'
  get 'test/9', :to => 'viewtest#ninth'
  # n user
  get 'test/front/1', :to => 'front#front_1'
  get 'test/front/2', :to => 'front#front_2'
  get 'test/front/3', :to => 'front#front_3'
  get 'test/front/mail1', :to => 'front#mail1'
  get 'test/front/mail2', :to => 'front#mail2'
  get 'test/front/mail3', :to => 'front#mail3'

  get 'test/delete_form', :to => 'viewtest#delete_form'



  # mail template
  get 'mail', :to => 'viewtest#mail'
  get 'mail2', :to => 'viewtest#mail2'

end
