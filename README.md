# Partnr
### Get Seriously Creative
Partnr is an online platform for students to showcase their work from hobby projects, school projects, and internships. Through our platform, we offer robust project management tools to help foster efficient group work while also enabling students to build impressive, credible portfolios. Students can create projects and tasks, and work with team members to complete important project milestones. As students complete tasks, they will propagate on that user’s profile and he will acquire the associated skills. With Partnr, you’ll never have to spend time updating your portfolio - your portfolio will update automatically as you develop your skillset.


## Set up the environment
to set up the environment for development you must have Virtualbox and Vagrant installed
run the following commands:

`vagrant up`
`vagrant ssh`

once inside the vagrant machine type:

`cd /vagrant`
`sudo ./setup.sh`

Some of the commands inside the setup.sh file must be done manually. If you have any questions about the commands in the file, contact Ryan.


## Set up the mailer
For local development, you should set up a local emailer.
Our email tool, mailcatcher, recommends that we install it ourselves instead of putting it into our Gemfile.

To install mailcatcher run:

`gem install mailcatcher`

then you should run mailcatcher in the background with the command:

`mailcatcher --http-ip=0.0.0.0`


## Run the server
To run the server, you should use the command:

`local=true rails s -b 0.0.0.0`

That will start a local server running on port 3000. You can connect to this by going to [localhost:3000](localhost:3000).
