# A model concern module to provide volatile counter cache logic to model class.
#
# @example
#   class Tweet < ActiveRecord::Base
#     include VolatileCounterCache
#     has_many :favorites
#     volatile_counter_cache :favorites, cache: Rails.cache
#   end
#   Tweet.first.favorites_count #=> 42
#   Tweet.first.favorites.first.destroy
#   Tweet.first.favorites_count #=> 41
#
module VolatileCounterCache
  CACHE_KEY_PREFIX = 'volatile-counter-cache'

  extend ActiveSupport::Concern

  module ClassMethods
    # Define counter method and callback using given cache store for 1:N association.
    # @param association_name [Symbol] Association name used to counter method, cache key, and counting.
    # @param cache [ActiveSupport::Cache::Store] A store object to store count for each key.
    # @param cache_options [Hash] Options for cache store.
    # @param counter_method_name [String] An optional String to change counter method name.
    # @param foreign_key [Symbol] An optional Symbol to change cache key at callback.
    def volatile_counter_cache(association_name, cache:, cache_options: {}, counter_method_name: nil, foreign_key: nil)
      counter_method_name = counter_method_name || "#{association_name}_count"
      cache_key_prefix = "#{CACHE_KEY_PREFIX}/#{model_name}/#{association_name}"

      define_method(counter_method_name) do
        cache.fetch("#{cache_key_prefix}/#{id}", cache_options) do
          send(association_name).count
        end
      end

      foreign_key = foreign_key || "#{table_name.singularize }_id"
      child_class = association_name.to_s.singularize.camelize.constantize
      callback_proc = -> do
        cache.delete("#{cache_key_prefix}/#{send(foreign_key)}", cache_options)
      end
      child_class.after_create(&callback_proc)
      child_class.after_destroy(&callback_proc)
    end
  end
end
