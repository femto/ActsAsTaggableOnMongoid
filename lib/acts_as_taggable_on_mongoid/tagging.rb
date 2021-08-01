module ActsAsTaggableOnMongoid
  class Tagging  #:nodoc:
    include Mongoid::Document
    include Mongoid::Timestamps
    #self.collection_name = ActsAsTaggableOnMongoid.taggings_table
    store_in collection:ActsAsTaggableOnMongoid.taggings_table

    belongs_to :tag

    field name, type: String #cache version of tag_name
    field :context, type: String
    field :tenant, type: String

    DEFAULT_CONTEXT = 'tags'
    belongs_to :tag, class_name: '::ActsAsTaggableOnMongoid::Tag', counter_cache: ActsAsTaggableOnMongoid.tags_counter
    belongs_to :taggable, polymorphic: true

    belongs_to :tagger, polymorphic: true, optional: true

    index({ context: 1 }, { name: "index_taggings_on_context" })

    index({:tag_id=>1, :taggable_id=>1, :taggable_type=>1, :context=>1, :tagger_id=>1, :tagger_type=>1}, {name: "taggings_idx", unique: true})

    index({:tag_id=>1}, {name: "index_taggings_on_tag_id"})
    index({:taggable_id=>1, :taggable_type=>1, :context=>1}, {name: "taggings_taggable_context_idx"})
    index({:taggable_id=>1, :taggable_type=>1, :tagger_id=>1, :context=>1}, {name: "taggings_idy"})

    index({:taggable_id=>1}, {name: "index_taggings_on_taggable_id"})
    index({:taggable_type=>1}, {name: "index_taggings_on_taggable_type"})
    index({:tagger_id=>1,:tagger_type=>1}, {name: "index_taggings_on_tagger_id_and_tagger_type"})
    index({:tagger_id=>1}, {name: "index_taggings_on_tagger_id"})
    index({:tenant=>1}, {name: "index_taggings_on_tenant"})

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
