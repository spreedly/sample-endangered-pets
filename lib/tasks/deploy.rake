namespace :deploy do

  desc "Deploy the sample app"
  task :sample do
    `git push heroku master:master`
  end

  desc "Deploy the sample app that has offsite stuff"
  task :sample_offsite do
    `git push heroku_offsite offsite:master`
  end
end
