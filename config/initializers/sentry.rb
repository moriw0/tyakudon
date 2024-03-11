Sentry.init do |config|
  config.dsn = 'https://e54ad48a6ce26bbb08d0c1f99c6098fd@o4506884486397952.ingest.us.sentry.io/4506884486594560'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
