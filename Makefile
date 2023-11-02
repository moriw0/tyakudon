bundle-install:
	docker-compose run --rm app bundle install --without production

bundle-update:
	docker-compose run --rm app bundle update

db-migrate:
	docker-compose run --rm app bundle exec rails db:migrate RAILS_ENV=development

precompile:
	docker-compose run --rm app bundle exec rails assets:precompile RAILS_ENV=development

test:
	docker-compose run --rm app bundle exec rails rspec

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down
