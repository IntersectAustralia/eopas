authorization do

  role :guest do
    has_permission_on :transcripts, :to => :read
  end

  role :user do
    has_permission_on :users, :to => :read
    has_permission_on :media_items, :to => :manage
    has_permission_on :transcripts, :to => :manage
    has_permission_on :transcript_phrases, :to => :manage
  end

  role :admin do
    includes :user
    has_permission_on :app_config, :to => :manage
  end
end

privileges do
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  privilege :manage, :includes => [:create, :read, :update, :delete, :upload_attachment]
end

