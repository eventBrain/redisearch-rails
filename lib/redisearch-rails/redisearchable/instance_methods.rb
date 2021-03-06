module RediSearch
  module RediSearchable
    module InstanceMethods

      def redisearch_document
        @redisearch_document ||= generate_redisearch_document
      end

      def redisearch_reindex(**options)
        RediSearch::RecordIndexer.new(self).reindex(options)
      end
      alias_method :reindex, :redisearch_reindex unless method_defined?(:reindex)

      def should_index?
        true
      end

      def redisearch_add
        redisearch_document.add(replace: true, partial: true)
      end

      def redisearch_delete
        redisearch_document.del(dd: true)
      end

      def redisearch_document_id
        [self.class.redisearch_index.name, self.id].join('_')
      end

      private

      def generate_redisearch_document
        index = self.class.redisearch_index
        serializer = redisearch_serializer || self
        fields = index.schema.fields.map(&:name)
        fields_values = Hash[fields.flatten.map! { |field| [field, serializer.public_send(field)] }]
        index.generate_document(redisearch_document_id, fields_values)
      end

      def redisearch_serializer
        self.class.redisearch_index_serializer.new(self) if self.class.redisearch_index_serializer
      end

    end
  end
end
