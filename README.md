# VolatileCounterCache
Provides volatile counter cache logic to ActiveRecord::Base.

## Usage
```ruby
class Tweet < ActiveRecord::Base
  include VolatileCounterCache

  has_many :favorites

  volatile_counter_cache :favorites, cache: Rails.cache
end

Tweet.first.favorites_count #=> 42
Tweet.first.favorites.first.destroy
Tweet.first.favorites_count #=> 41
```

### options
- cache [ActiveSupport::Cache::Store] A store object to store count for each key.
- cache_options [Hash] Options for cache store.
- counter_method_name [String] An optional String to change counter method name.
- foreign_key [Symbol] An optional Symbol to change cache key at callback.
