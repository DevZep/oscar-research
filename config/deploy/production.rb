set :stage, 'production'

server '13.250.154.124', user: 'deployer', roles: %w{app web db}
