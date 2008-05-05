namespace :letterpress do
  namespace :images do
    desc "Clears previously generated images"
    task :clear => :environment do
      FileUtils.rm(Dir["public/images/#{Letterpress::Config.images_dir}/[^.]*"])
    end
  end
end
