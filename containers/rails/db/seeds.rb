SeedFu.seed(nil, /load_master_data/)
SeedFu.seed(nil, /sample_user/) if ['development', 'test'].include? Rails.env
SeedFu.seed(nil, /sample_favorite/) if ['development', 'test'].include? Rails.env
SeedFu.seed(nil, /sample_record/) if ['development', 'test'].include? Rails.env
SeedFu.seed(nil, /sample_line_status/) if ['development', 'test'].include? Rails.env
