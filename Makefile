bundle-install:
	docker-compose run --rm app bundle install --without production

bundle-update:
	docker-compose run --rm app bundle update

db-migrate:
	docker-compose run --rm app bundle exec rails db:migrate RAILS_ENV=development

db-seed:
	docker-compose run --rm app bundle exec rails db:seed RAILS_ENV=development

precompile:
	docker-compose run --rm app bundle exec rails assets:precompile RAILS_ENV=development

rspec:
	docker-compose exec app bundle exec rspec

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

scraping:
	docker-compose run --rm app bundle exec thor scraping:scrape_ramen_shops --limit=3 --resume=true --wait_seconds=3

c:
	docker-compose run --rm app bundle exec rails c
