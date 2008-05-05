config.after_initialize do
  ActionController::Base.helper(Letterpress)
end