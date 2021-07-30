module ActsAsTaggableOnMongoid
  class Tagging  #:nodoc:
    include Mongoid::Document
    include Mongoid::Timestamps
    #self.table_name = ActsAsTaggableOnMongoid.taggings_table

    field :tag_id, type: Integer
    belongs_to :taggable, polymorphic: true
    belongs_to :tagger, polymorphic: true
    field :context, type: String
    field :tenant, type: String

    DEFAULT_CONTEXT = 'tags'
    belongs_to :tag, class_name: '::ActsAsTaggableOnMongoid::Tag', counter_cache: ActsAsTaggableOnMongoid.tags_counter
    belongs_to :taggable, polymorphic: true

    belongs_to :tagger, polymorphic: true, optional: true

    scope :owned_by, ->(owner) { where(tagger: owner) }
    scope :not_owned, -> { where(tagger_id: nil, tagger_type: nil) }

    scope :by_contexts, ->(contexts) { where(context: (contexts || DEFAULT_CONTEXT)) }
    scope :by_context, ->(context = DEFAULT_CONTEXT) { by_contexts(context.to_s) }

    scope :by_tenant, ->(tenant) { where(tenant: tenant) }

    validates_presence_of :context
    validates_presence_of :tag_id

    validates_uniqueness_of :tag_id, scope: [:taggable_type, :taggable_id, :context, :tagger_id, :tagger_type]

    after_destroy :remove_unused_tags

    private

    def remove_unused_tags
      if ActsAsTaggableOnMongoid.remove_unused_tags
        if ActsAsTaggableOnMongoid.tags_counter
          tag.destroy if tag.reload.taggings_count.zero?
        else
          tag.destroy if tag.reload.taggings.none?
        end
      end
    end
  end
end