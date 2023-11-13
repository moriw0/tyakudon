bundle-install:
	docker-compose run --rm app bundle install --without production

bundle-update:
	docker-compose run --rm app bundle update

db-migrate:
	docker-compose run --rm app bundle exec rails db:migrate RAILS_ENV=development

precompile:
	docker-compose run --rm app bundle exec rails assets:precompile RAILS_ENV=development

test:
	docker-compose run --rm app bundle exec rspec

build:
	docker-compose build

upd:
	docker-compose up -d

up:
	docker-compose up

down:
	docker-compose down

logs:
	docker-compose logs

logsf:
	docker-compose logs -f
