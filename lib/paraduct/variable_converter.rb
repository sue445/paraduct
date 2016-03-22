module Paraduct
  class VariableConverter
    # @param variables [Hash{String => Array<String>}] Key: variable name, Value: values_pattern which you want to product
    # @return [Array<Hash{String => String}>]
    def self.product(variables)
      return [] if variables.empty?

      values_patterns = product_array(variables.values)

      product_variables = []
      values_patterns.each do |values_pattern|
        entry  = {}
        keys   = variables.keys.to_enum
        values = values_pattern.to_enum

        loop do
          key   = keys.next
          value = values.next
          entry[key] = value
        end

        product_variables << entry
      end
      product_variables
    end

    def self.reject(product_variables, exclude_variables)
      product_variables.inject([]) do |rejected_product_variables, variables|
        rejected_product_variables << variables unless exclude_variables.any? { |exclude| partial_match?(variables, exclude) }
        rejected_product_variables
      end
    end

    def self.partial_match?(parent_hash, child_hash)
      child_hash.each do |k, v|
        return false unless parent_hash[k] == v
      end
      true
    end

    def self.product_array(array)
      first_values = array.shift
      if array.empty?
        first_values.product
      else
        first_values.product(*array)
      end
    end
    private_class_method :product_array
  end
end
