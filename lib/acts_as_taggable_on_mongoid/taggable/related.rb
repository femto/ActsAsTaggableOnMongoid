module ActsAsTaggableOnMongoid::Taggable
  module Related
    def self.included(base)
      base.extend ActsAsTaggableOnMongoid::Taggable::Related::ClassMethods
      base.initialize_acts_as_taggable_on_related
    end

    module ClassMethods
      def initialize_acts_as_taggable_on_related
        tag_types.map(&:to_s).each do |tag_type|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def find_related_#{tag_type}(options = {})
              related_tags_for('#{tag_type}', self.class, options)
            end
            alias_method :find_related_on_#{tag_type}, :find_related_#{tag_type}

            def find_related_#{tag_type}_for(klass, options = {})
              related_tags_for('#{tag_type}', klass, options)
            end
          RUBY
        end
      end

      def acts_as_taggable_on(*args)
        super(*args)
        initialize_acts_as_taggable_on_related
      end
    end

    def find_matching_contexts(search_context, result_context, options = {})
      matching_contexts_for(search_context.to_s, result_context.to_s, self.class, options)
    end

    def find_matching_contexts_for(klass, search_context, result_context, options = {})
      matching_contexts_for(search_context.to_s, result_context.to_s, klass, options)
    end

    def matching_contexts_for(search_context, result_context, klass, options = {})
      tags_to_find = tags_on(search_context).map { |t| t.name }
      related_where(klass, ["#{exclude_self(klass, id)} #{klass.collection_name}.#{klass.primary_key} = #{ActsAsTaggableOnMongoid::Tagging.collection_name}.taggable_id AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.taggable_type = '#{klass.base_class}' AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.tag_id = #{ActsAsTaggableOnMongoid::Tag.collection_name}.#{ActsAsTaggableOnMongoid::Tag.primary_key} AND #{ActsAsTaggableOnMongoid::Tag.collection_name}.name IN (?) AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.context = ?", tags_to_find, result_context])
    end

    def related_tags_for(context, klass, options = {})
      tags_to_ignore = Array.wrap(options[:ignore]).map(&:to_s) || []
      tags_to_find = tags_on(context).map { |t| t.name }.reject { |t| tags_to_ignore.include? t }
      related_where(klass, ["#{exclude_self(klass, id)} #{klass.collection_name}.#{klass.primary_key} = #{ActsAsTaggableOnMongoid::Tagging.collection_name}.taggable_id AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.taggable_type = '#{klass.base_class}' AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.tag_id = #{ActsAsTaggableOnMongoid::Tag.collection_name}.#{ActsAsTaggableOnMongoid::Tag.primary_key} AND #{ActsAsTaggableOnMongoid::Tag.collection_name}.name IN (?) AND #{ActsAsTaggableOnMongoid::Tagging.collection_name}.context = ?", tags_to_find, context])
    end

    private

    def exclude_self(klass, id)
      "#{klass.arel_table[klass.primary_key].not_eq(id).to_sql} AND" if [self.class.base_class, self.class].include? klass
    end

    def group_columns(klass)
      if ActsAsTaggableOnMongoid::Utils.using_postgresql?
        grouped_column_names_for(klass)
      else
        "#{klass.collection_name}.#{klass.primary_key}"
      end
    end

    def related_where(klass, conditions)
      klass.select("#{klass.collection_name}.*, COUNT(#{ActsAsTaggableOnMongoid::Tag.collection_name}.#{ActsAsTaggableOnMongoid::Tag.primary_key}) AS count")
      .from("#{klass.collection_name}, #{ActsAsTaggableOnMongoid::Tag.collection_name}, #{ActsAsTaggableOnMongoid::Tagging.collection_name}")
      .group(group_columns(klass))
      .order('count DESC')
      .where(conditions)
    end
  end
end
