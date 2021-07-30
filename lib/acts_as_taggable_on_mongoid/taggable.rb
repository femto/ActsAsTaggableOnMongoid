module ActsAsTaggableOnMongoid
  module Taggable
    extend ActiveSupport::Concern
    class_methods do
      def taggable?
        false
      end

      ##
      # This is an alias for calling <tt>acts_as_taggable_on :tags</tt>.
      #
      # Example:
      #   class Book < ActiveRecord::Base
      #     acts_as_taggable
      #   end
      def acts_as_taggable
        acts_as_taggable_on :tags
      end

      ##
      # This is an alias for calling <tt>acts_as_ordered_taggable_on :tags</tt>.
      #
      # Example:
      #   class Book < ActiveRecord::Base
      #     acts_as_ordered_taggable
      #   end
      def acts_as_ordered_taggable
        acts_as_ordered_taggable_on :tags
      end

      ##
      # Make a model taggable on specified contexts.
      #
      # @param [Array] tag_types An array of taggable contexts
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_taggable_on :languages, :skills
      #   end
      def acts_as_taggable_on(*tag_types)
        taggable_on(false, tag_types)
      end

      ##
      # Make a model taggable on specified contexts
      # and preserves the order in which tags are created
      #
      # @param [Array] tag_types An array of taggable contexts
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_ordered_taggable_on :languages, :skills
      #   end
      def acts_as_ordered_taggable_on(*tag_types)
        taggable_on(true, tag_types)
      end

      def acts_as_taggable_tenant(tenant)
        if taggable?
          self.tenant_column = tenant
        else
          class_attribute :tenant_column
          self.tenant_column = tenant
        end

        # each of these add context-specific methods and must be
        # called on each call of taggable_on
        include Core
        include Collection
        include Cache
        include Ownership
        include Related
      end

      private

      # Make a model taggable on specified contexts
      # and optionally preserves the order in which tags are created
      #
      # Separate methods used above for backwards compatibility
      # so that the original acts_as_taggable_on method is unaffected
      # as it's not possible to add another argument to the method
      # without the tag_types being enclosed in square brackets
      #
      # NB: method overridden in core module in order to create tag type
      #     associations and methods after this logic has executed
      #
      def taggable_on(preserve_tag_order, *tag_types)
        tag_types = tag_types.to_a.flatten.compact.map(&:to_sym)

        if taggable?
          self.tag_types = (self.tag_types + tag_types).uniq
          self.preserve_tag_order = preserve_tag_order
        else
          class_attribute :tag_types
          self.tag_types = tag_types
          class_attribute :preserve_tag_order
          self.preserve_tag_order = preserve_tag_order
          class_attribute :tenant_column

          class_eval do
            has_many :taggings, as: :taggable, dependent: :destroy, class_name: '::ActsAsTaggableOnMongoid::Tagging'
            has_many :tags, class_name: '::ActsAsTaggableOnMongoid::Tag'

            def self.taggable?
              true
            end
          end
        end

        # each of these add context-specific methods and must be
        # called on each call of taggable_on
        include Core
        include Collection
        include Cache
        include Ownership
        include Related
      end
    end
  end
end
