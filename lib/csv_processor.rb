# frozen_string_literal: true

require "csv"

module CSVProcessor
  class << self
    # NOTE: Loads entire CSV into memory to simplify processing.
    # For very large files, consider streaming rows with CSV.foreach
    # with two file reads to reduce memory footprint.
    def process(path, field_groups, &block)
      rows = CSV.read(path, headers: true)
      process_rows(rows, field_groups, &block)
    end

    def process_rows(rows, field_groups, &block)
      return if rows.empty?

      nodes = compute_nodes(rows, field_groups)
      each_new_row(rows, nodes, &block)
    end

    private

    def compute_nodes(rows, field_groups)
      node_mapper = NodeMapper.new(field_groups)
      rows.map { |row| node_mapper.node_for(row) }
    end

    def each_new_row(rows, nodes, &block)
      new_headers = ["ID"] + rows.first.headers
      rows.each_with_index do |row, i|
        root_id = nodes[i].root_id
        new_row = CSV::Row.new(new_headers, [root_id] + row.fields)
        block.call(new_row)
      end
    end
  end

  class NodeMapper
    def initialize(field_groups)
      @key_builder = KeyBuilder.new(field_groups)
      @nodes_by_key = {}
    end

    def node_for(row)
      keys = @key_builder.build(row)

      return Node.new if keys.empty?

      nodes = find_root_nodes(keys)
      case nodes.size
      when 0 then create_node(keys)
      when 1 then add_to_node(keys, nodes.first)
      else merge_nodes(keys, nodes)
      end
    end

    private

    def find_root_nodes(keys)
      @nodes_by_key.values_at(*keys).compact.map(&:root).uniq
    end

    def create_node(keys)
      new_node = Node.new
      set_keys(keys, new_node)
      new_node
    end

    def add_to_node(keys, node)
      set_keys(keys, node)
      node
    end

    def merge_nodes(keys, nodes)
      new_node = Node.new
      nodes.each { |node| node.change_root(new_node) }
      set_keys(keys, new_node)
      new_node
    end

    def set_keys(keys, node)
      keys.each { |key| @nodes_by_key[key] = node }
    end
  end
end
