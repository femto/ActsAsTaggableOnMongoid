module ActsAsTaggableOnMongoid::Taggable::TaggedWithQuery
  class QueryBase
    def initialize(taggable_model, tag_model, tagging_model, tag_list, options)
      @taggable_model = taggable_model
      @tag_model      = tag_model
      @tagging_model  = tagging_model
      @tag_list       = tag_list
      @options        = options
    end

    def base_computed_taggable
      taggings = ActsAsTaggableOnMongoid::Tagging.in(name:tag_list).where(taggable_type:taggable_model)
      taggings = taggings.where(context: options[:on]) if  options[:on]
      taggable = taggings.map(&:taggable).uniq
    end

    private

    attr_reader :taggable_model, :tag_model, :tagging_model, :tag_list, :options

    def taggable_arel_table
      @taggable_arel_table ||= taggable_model
    end

    def tag_arel_table
      @tag_arel_table ||= tag_model
    end

    def tagging_arel_table
      @tagging_arel_table ||=tagging_model
    end

    def tag_match_type(tag)
      matches_attribute = tag_arel_table[:name]
      matches_attribute = matches_attribute.lower unless ActsAsTaggableOn.strict_case_match

      if options[:wild].present?
        matches_attribute.matches("%#{escaped_tag(tag)}%", "!", ActsAsTaggableOn.strict_case_match)
      else
        matches_attribute.matches(escaped_tag(tag), "!", ActsAsTaggableOn.strict_case_match)
      end
    end

    def tags_match_type
      matches_attribute = tag_arel_table[:name]
      matches_attribute = matches_attribute.lower unless ActsAsTaggableOn.strict_case_match

      if options[:wild].present?
        matches_attribute.matches_any(tag_list.map{|tag| "%#{escaped_tag(tag)}%"}, "!", ActsAsTaggableOn.strict_case_match)
      else
        matches_attribute.matches_any(tag_list.map{|tag| "#{escaped_tag(tag)}"}, "!", ActsAsTaggableOn.strict_case_match)
      end
    end

    def escaped_tag(tag)
      tag = tag.downcase unless ActsAsTaggableOn.strict_case_match
      ActsAsTaggableOnMongoid::Utils.escape_like(tag)
    end

    def adjust_taggings_alias(taggings_alias)
      if taggings_alias.size > 75
        taggings_alias = 'taggings_alias_' + Digest::SHA1.hexdigest(taggings_alias)
      end
      taggings_alias
    end
  end
end
