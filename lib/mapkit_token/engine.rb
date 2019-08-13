module MapkitToken
  class Engine < Rails::Engine
    initialize "mapkit_token.load_app_instance_data" do |app|
      MapkitToken.setup do |config|
        config.app_root = app.root
      end
    end

    initialize "mapkit_token.load_static_assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
