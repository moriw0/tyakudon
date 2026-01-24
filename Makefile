bundle-install:
	docker compose run --rm app bundle install --without production

bundle-update:
	docker compose run --rm app bundle update

db-migrate:
	docker compose run --rm app bundle exec rails db:migrate RAILS_ENV=development

db-rollback:
	docker compose run --rm app bundle exec rails db:rollback RAILS_ENV=development

db-status:
	docker compose run --rm app bundle exec rails db:migrate:status RAILS_ENV=development

db-seed:
	docker compose run --rm app bundle exec rails db:seed RAILS_ENV=development

precompile:
	docker compose run --rm app bundle exec rails assets:precompile RAILS_ENV=development

rspec:
	docker compose exec app bundle exec rspec

bash:
	docker compose exec app bash

build:
	docker compose build

upd:
	docker compose up -d

up:
	docker compose up

down:
	docker compose down

restart:
	docker compose restart

attach:
	docker attach tyakudon-app-1

logs:
	docker compose logs

logsf:
	docker compose logs -f

scraping:
	docker compose run --rm app bundle exec thor scraping:scrape_ramen_shops --limit=3 --resume=true --wait_seconds=3

c:
	docker compose run --rm app bundle exec rails c
