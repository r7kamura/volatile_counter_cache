# VolatileCounterCache
Provides volatile counter cache logic to ActiveRecord::Base.

## Usage
1. `favorites_count` tries to read counter cache from Rails.cache.
2. If there is no cache yet, it calls `favorites.size` and store the result.
3. When `favorite` is created or destroyed, the cache is purged.

```ruby
class Tweet < ActiveRecord::Base
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
