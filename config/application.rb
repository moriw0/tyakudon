require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tyakudon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Rails 7.1
    #
    # Enable validating only parent-related columns for presence when the parent is mandatory.
    # The previous behavior was to validate the presence of the parent record, which performed an extra query
    # to get the parent every time the child record was updated, even when parent has not changed.
    config.active_record.belongs_to_required_validates_foreign_key = false # New default is false

    # No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't be able
    # to manually require files that are managed by the autoloader, which you shouldn't do anyway.
    #
    # This will reduce the size of the load path, making `require` faster if you don't use bootsnap, or reduce the size
    # of the bootsnap cache if you use it.
    config.add_autoload_paths_to_load_path = false # New default is false

    # Change the format of the cache entry.
    #
    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 7.0
    # applications.
    #
    # Only change this value after your application is fully deployed to Rails 7.1
    # and you have no plans to rollback.
    config.active_support.cache_format_version = 7.1 # New default is 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
    end
    config.active_storage.variant_processor = :vips
    config.active_job.queue_adapter = :good_job
    config.good_job = {
      execution_mode: :async,
      max_threads: 4
    }
  end
end
