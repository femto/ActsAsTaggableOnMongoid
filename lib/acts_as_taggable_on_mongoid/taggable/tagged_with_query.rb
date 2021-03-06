require_relative 'tagged_with_query/query_base'
require_relative 'tagged_with_query/exclude_tags_query'
require_relative 'tagged_with_query/any_tags_query'
require_relative 'tagged_with_query/all_tags_query'

module ActsAsTaggableOnMongoid::Taggable::TaggedWithQuery
  def self.build(taggable_model, tag_model, tagging_model, tag_list, options)
    if options[:exclude].present?
      ExcludeTagsQuery.new(taggable_model, tag_model, tagging_model, tag_list, options).build
    elsif options[:all].present?
      AllTagsQuery.new(taggable_model, tag_model, tagging_model, tag_list, options).build
    else
      AnyTagsQuery.new(taggable_model, tag_model, tagging_model, tag_list, options).build
    end
  end
end
