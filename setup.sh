sudo apt-get update
sudo apt-get install -y build-essential zlib1g-dev git-core gnupg2 libpq-dev postgresql imagemagick
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -L https://get.rvm.io | bash -s stable --ruby
source /home/vagrant/.rvm/scripts/rvm
rvm install ruby-2.3.0
source ~/.profile
rvm use 2.3.0
gem install bundler
bundle
export AWS_REGION="us-west-2"
gem install mailcatcher --no-ri --no-doc
sudo -u postgres -s createuser -s vagrant
rake db:setup
